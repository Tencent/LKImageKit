//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageProcessorManager.h"
#import "LKImageDefine.h"
#import "LKImageInfo.h"
#import "LKImagePrivate.h"
#import "LKImageUtil.h"
#import <stdatomic.h>

@implementation LKImageProcessor

- (NSString *)identify
{
    return NSStringFromClass([self class]);
}

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *, NSError *))complete
{
    complete(input, nil);
}

@end

@interface LKImageProcessorManager ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation LKImageProcessorManager

+ (instancetype)defaultManager
{
    static LKImageProcessorManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.queue                             = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 10;
        self.queue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
    }
    return self;
}

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *, NSError *))complete
{
    lkweakify(self);
    request.processorOperation = [NSBlockOperation blockOperationWithBlock:^{
        lkstrongify(self);
        [self process:input request:request index:0 complete:complete];
        request.processorOperation = nil;
    }];
    [self.queue lk_addOperation:request.processorOperation request:request];
}

- (void)process:(UIImage *)input request:(LKImageRequest *)request index:(NSInteger)index complete:(void (^)(UIImage *, NSError *))complete
{
    if (!input)
    {
        complete(nil, [LKImageError errorWithCode:LKImageErrorCodeProcessorFailed]);
        return;
    }
    if (index >= request.processorList.count)
    {
        complete(input, nil);
        return;
    }

    LKImageProcessor *processor = request.processorList[index];
    //for mutiple images
    if (input.images.count > 0)
    {
        __block atomic_int rest = input.images.count;

        NSMutableArray *array            = [NSMutableArray arrayWithCapacity:input.images.count];
        __block NSError *processor_error = nil;
        __block UIImage *processor_image = nil;
        for (NSUInteger i = 0; i < input.images.count; i++)
        {
            [array addObject:[NSNull null]];
            [processor process:input.images[i]
                       request:request
                      complete:^(UIImage *output, NSError *error) {

                          atomic_fetch_sub(&rest, 1);
                          if (!output && !error)
                          {
                              error = [LKImageError errorWithCode:LKImageErrorCodeProcessorFailed];
                          }
                          if (error)
                          {
                              processor_error = error;
                          }
                          else
                          {
                              array[i] = output;
                              if (rest == 0)
                              {
                                  processor_image              = [UIImage animatedImageWithImages:array duration:INFINITY];
                                  processor_image.lk_imageInfo = input.lk_imageInfo;
                              }
                          }

                      }];
            if (processor_error)
            {
                break;
            }
        }
        if (!processor_error)
        {
            [self process:processor_image request:request index:index + 1 complete:complete];
        }
        else
        {
            complete(processor_image, processor_error);
        }
    }
    //for single image
    else
    {
        [processor process:input
                   request:request
                  complete:^(UIImage *output, NSError *error) {
                      if (!output.lk_imageInfo)
                      {
                          output.lk_imageInfo = input.lk_imageInfo;
                      }

                      if (!error)
                      {
                          [self process:output request:request index:index + 1 complete:complete];
                      }
                      else
                      {
                          complete(output, error);
                      }

                  }];
    }
}

+ (NSString *)keyForProcessorList:(NSArray *)processorList
{
    NSMutableString *str = [[NSMutableString alloc] init];
    for (LKImageProcessor *processor in processorList)
    {
        [str appendFormat:@"-%@", processor.identify];
    }
    return str;
}

@end
