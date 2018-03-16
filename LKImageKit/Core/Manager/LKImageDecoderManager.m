//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageDecoderManager.h"
#import "LKImageDefine.h"
#import "LKImagePrivate.h"
#import "LKImageUtil.h"
#import "LKImageMonitor.h"

@implementation LKImageDecodeResult

@end

@implementation LKImageDecoder

- (LKImageDecodeResult *)decodeResultFromData:(NSData *)data request:(LKImageRequest *)request
{
    return nil;
}

@end

@interface LKImageDecoderManager ()

@property (nonatomic, strong) NSMutableArray<LKImageDecoder *> *decoderList;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation LKImageDecoderManager

+ (instancetype)defaultManager
{
    static LKImageDecoderManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    return [self initWithDecoderList:nil];
}

- (instancetype)initWithDecoderList:(NSArray<LKImageDecoder *> *)decoderList
{
    if (self = [super init])
    {
        _queue                             = [[NSOperationQueue alloc] init];
        _queue.qualityOfService            = NSQualityOfServiceUserInteractive;
        _queue.maxConcurrentOperationCount = 10;
        _queue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
        
        self.decoderList = [NSMutableArray arrayWithArray:decoderList];
    }
    return self;
}

- (void)registerDecoder:(LKImageDecoder *)decoder
{
    [self.decoderList addObject:decoder];
}

- (void)unregisterDecoder:(LKImageDecoder *)decoder
{
    [self.decoderList removeObject:decoder];
}

- (void)unregisterAllDecoder
{
    [self.decoderList removeAllObjects];
}

- (void)_decodeImageFromData:(NSData *)data request:(LKImageRequest *)request complete:(LKImageDecoderCallback)complete
{
    NSDate *date = [NSDate date];
    NSError *error = nil;
    if (request.error)
    {
        if (complete)
        {
            complete(request, nil, request.error);
        }
        goto end;
    }
    
    if (!data)
    {
        if (complete)
        {
            complete(request, nil, [LKImageError errorWithCode:LKImageErrorCodeDataEmpty]);
        }
        goto end;
    }
    BOOL found          = NO;
    request.isDecoding  = YES;
    for (LKImageDecoder *decoder in self.decoderList)
    {
        LKImageDecodeResult *result = [decoder decodeResultFromData:data request:request];
        if (result)
        {
            if (result.image)
            {
                request.imageType = result.type;
                request.decoder = decoder;
                request.decodeDuration = [[NSDate date] timeIntervalSinceDate:date];
                if (complete)
                {
                    complete(request, result.image, nil);
                }
                request.isDecoding = NO;
                goto end;
            }
            else
            {
                if (result.error)
                {
                    error = result.error;
                }
                found = YES;
                if (!self.continueTryToDecodeWhenFailed)
                {
                    break;
                }
            }
            
        }
    }
    
    request.isDecoding = NO;
    if (found)
    {
        if (!error)
        {
            error = [LKImageError errorWithCode:LKImageErrorCodeDecodeFailed];
        }
        if (complete)
        {
            complete(request, nil, error);
        }
    }
    else
    {
        if (complete)
        {
            complete(request, nil, [LKImageError errorWithCode:LKImageErrorCodeDecoderNotFound]);
        }
    }
end:
    if (request.progress >= 1)
    {
        request.decoderAttach   = nil;
    }
    [[LKImageMonitor instance] requestDidFinishDecode:request];
}

- (void)decodeImageFromData:(NSData *)data request:(LKImageRequest *)request complete:(LKImageDecoderCallback)complete
{
    if (request.isDecoding && request.progress < 1)
    {
        complete(request, nil, [LKImageError errorWithCode:LKImageErrorCodeRequestIsDecoding]);
    }
    else
    {
        lkweakify(self);
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            lkstrongify(self);
            NSDate *date = [NSDate date];
            [self _decodeImageFromData:data request:request complete:complete];
            @synchronized(request)
            {
                request.decodeOperation = nil;
            }
            LKImageLogInfo([NSString stringWithFormat:@"%@ decode:%f",request,[[NSDate date] timeIntervalSinceDate:date]]);
            
        }];
        @synchronized(request)
        {
            if (request.decodeOperation)
            {
                [op addDependency:request.decodeOperation];
            }
        }
        
        request.decodeOperation = op;
        [self.queue lk_addOperation:op request:request];
    }
}

- (NSMutableArray<LKImageDecoder *> *)decoderList
{
    if (!_decoderList)
    {
        _decoderList = [NSMutableArray array];
    }
    return _decoderList;
}

@end
