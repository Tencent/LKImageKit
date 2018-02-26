//
//  LKImageDecoderManager.m
//  LKImageKit
//
//  Created by lingtonke on 2016/12/29.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageDecoderManager.h"
#import "LKImageDefine.h"
#import "LKImagePrivate.h"
#import "LKImageUtil.h"

@implementation LKImageDecoder

- (UIImage *)imageFromData:(NSData *)data request:(LKImageRequest *)request error:(NSError *__autoreleasing *)error
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
    BOOL found         = NO;
    request.isDecoding = YES;
    for (LKImageDecoder *decoder in self.decoderList)
    {
        NSError *decode_error;
        UIImage *image = [decoder imageFromData:data request:request error:&decode_error];
        if (image)
        {
            if (complete)
            {
                complete(request, image, nil);
            }
            request.isDecoding = NO;
            goto end;
        }
        else
        {
            if (decode_error)
            {
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
        if (complete)
        {
            complete(request, nil, [LKImageError errorWithCode:LKImageErrorCodeDecodeFailed]);
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
