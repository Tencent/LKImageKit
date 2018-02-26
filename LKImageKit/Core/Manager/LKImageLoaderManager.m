//
//  LKImageLoaderManager.m
//  LKImageKit
//
//  Created by lingtonke on 15/8/31.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageLoaderManager.h"
#import "LKImageDecoderManager.h"
#import "LKImageDefine.h"
#import "LKImagePriorityArray.h"
#import "LKImagePrivate.h"
#import "LKImageUtil.h"
#import <objc/runtime.h>
@interface LKImageLoader ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation LKImageLoader

- (instancetype)init
{
    if (self = [super init])
    {
        self.gcd_queue                         = dispatch_queue_create(nil, nil);
        self.queue                             = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.queue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
        self.semaphore                         = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount
{
    self.queue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

- (NSUInteger)maxConcurrentOperationCount
{
    return self.queue.maxConcurrentOperationCount;
}

- (BOOL)isValidRequest:(LKImageRequest *)request
{
    return NO;
}

- (LKImageLoaderCancelResult)cancelRequest:(LKImageRequest *)request
{
    return LKImageLoaderCancelResultFinishImmediately;
}

- (void)willBeRegistered
{
    
}

- (void)didBeUnregistered
{
    
}

@end

@interface LKImageLoaderManager ()

@property (nonatomic, strong) NSMutableArray<id<LKImageLoaderProtocol>> *loaderList;
@property (nonatomic, strong) NSMutableDictionary<NSString *, LKImageRequest *> *requestDic;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation LKImageLoaderManager

+ (instancetype)defaultManager
{
    static LKImageLoaderManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance                = [[self alloc] initWithLoaderList:nil decoderList:nil];
        instance.decoderManager = [LKImageDecoderManager defaultManager];
    });
    return instance;
}

- (instancetype)init
{
    return [self initWithLoaderList:nil decoderList:nil];
}

- (instancetype)initWithLoaderList:(NSArray<LKImageLoader *> *)loaderList decoderList:(NSArray<LKImageDecoder *> *)decoderList
{
    if (self = [super init])
    {
        self.decoderManager                    = [[LKImageDecoderManager alloc] init];
        self.queue                             = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.queue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
        for (LKImageLoader *loader in loaderList)
        {
            [loader willBeRegistered];
        }
        self.loaderList                        = [NSMutableArray arrayWithArray:loaderList];
        if (decoderList)
        {
            self.decoderManager = [[LKImageDecoderManager alloc] initWithDecoderList:decoderList];
        }
    }
    return self;
}

- (void)registerLoader:(LKImageLoader *)loader
{
    [loader willBeRegistered];
    [self.loaderList addObject:loader];
}

- (void)unregisterLoader:(LKImageLoader *)loader
{
    [self.loaderList removeObject:loader];
    [loader didBeUnregistered];
}

- (void)unregisterAllLoader
{
    NSArray *loaderList = [self.loaderList copy];
    [self.loaderList removeAllObjects];
    for (LKImageLoader *loader in loaderList)
    {
        [loader didBeUnregistered];
    }
}

- (id<LKImageLoaderProtocol>)loaderForRequest:(LKImageRequest *)request
{
    for (id<LKImageLoaderProtocol> loader in self.loaderList)
    {
        if ([loader isValidRequest:request])
        {
            return loader;
        }
    }
    return nil;
}

- (void)requestDidFinished:(LKImageRequest *)requestLV2
{
    if (!requestLV2.synchronized)
    {
        [self.requestDic removeObjectForKey:requestLV2.keyForLoader];
    }
    requestLV2.isFinished = YES;
    for (LKImageRequest *requestLV1 in requestLV2.requestList)
    {
        requestLV1.isFinished = YES;
        [requestLV1.loaderManagerCancelOperation cancel];
    }
}

- (void)loadDataRequestFinished:(LKImageRequest*)requestLV2 data:(NSData*)data progress:(float)progress error:(NSError*)error
{
    if (requestLV2.isFinished)
    {
        return;
    }
    if (error || progress >= 1)
    {
        requestLV2.isFinished = YES;
        if (!requestLV2.synchronized)
        {
            dispatch_semaphore_signal(requestLV2.loader.semaphore);
        }
    }
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        requestLV2.progress = progress;
        requestLV2.error    = error;
        if (requestLV2.progress >= 1 || requestLV2.error)
        {
            [self requestDidFinished:requestLV2];
        }
        
        if (requestLV2.supportProgressive || requestLV2.progress >= 1)
        {
            if (!requestLV2.loaderCallbackCount)
            {
                return;
            }
            [self.decoderManager decodeImageFromData:data
                                             request:requestLV2
                                            complete:^(LKImageRequest *request, UIImage *image, NSError *error) {
                                                NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                                                    if (!request.supportProgressive)
                                                    {
                                                        request.error = error;
                                                    }
                                                    
                                                    if (image)
                                                    {
                                                        [request loaderCallback:image];
                                                    }
                                                    else
                                                    {
                                                        if (progress >= 1&&!request.error)
                                                        {
                                                            request.error = [LKImageError errorWithCode:LKImageErrorCodeDecodeFailed];
                                                        }
                                                        [request loaderCallback:nil];
                                                    }
                                                }];
                                                [self.queue lk_addOperation:op request:request];
                                            }];
        }
        else
        {
            if (progress >= 1)
            {
                if (!requestLV2.error)
                {
                    requestLV2.error = [LKImageError errorWithCode:LKImageErrorCodeDataEmpty];
                }
            }
            [requestLV2 loaderCallback:nil];
        }
    }];
    [self.queue lk_addOperation:op request:requestLV2];
}

- (void)loadImageRequestFinished:(LKImageRequest*)requestLV2 image:(UIImage*)image progress:(float)progress error:(NSError*)error
{
    if (requestLV2.isFinished)
    {
        return;
    }
    if (error || progress >= 1)
    {
        requestLV2.isFinished = YES;
        if (!requestLV2.synchronized)
        {
            dispatch_semaphore_signal(requestLV2.loader.semaphore);
        }
    }
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        requestLV2.progress = progress;
        requestLV2.error    = error;
        if (requestLV2.progress >= 1 || requestLV2.error)
        {
            [self requestDidFinished:requestLV2];
        }
        if (!requestLV2.error && requestLV2.progress >= 1 && !image)
        {
            requestLV2.error = [LKImageError errorWithCode:LKImageErrorCodeLoaderReturnNoImage];
        }
        if (error)
        {
            [requestLV2 loaderCallback:nil];
        }
        else
        {
            if (requestLV2.supportProgressive || requestLV2.progress >= 1)
            {
                [requestLV2 loaderCallback:image];
            }
            else
            {
                if (progress >= 1 && !image)
                {
                    if (!requestLV2.error)
                    {
                        requestLV2.error = [LKImageError errorWithCode:LKImageErrorCodeDataEmpty];
                    }
                }
                [requestLV2 loaderCallback:nil];
            }
        }
        
    }];
    [self.queue lk_addOperation:op request:requestLV2];
}

- (void)loadRequest:(LKImageRequest *)requestLV2
{
    if ([requestLV2.loader respondsToSelector:@selector(dataWithRequest:callback:)])
    {
        lkweakify(self);
        requestLV2.loaderOperation = [NSBlockOperation blockOperationWithBlock:^{
            lkstrongify(self);
            if (requestLV2.isCanceled)
            {
                return;
            }
            LKDispatch(requestLV2.synchronized, requestLV2.loader.gcd_queue, ^{
                if (requestLV2.isCanceled)
                {
                    return;
                }
                requestLV2.isStarted = YES;
                [requestLV2.loader dataWithRequest:requestLV2
                                          callback:^(LKImageRequest *requestLV2, NSData *data, float progress, NSError *error) {
                                              [self loadDataRequestFinished:requestLV2 data:data progress:progress error:error];
                                          }];
            });
            if (!requestLV2.synchronized)
            {
                dispatch_semaphore_wait(requestLV2.loader.semaphore, DISPATCH_TIME_FOREVER);
            }
            requestLV2.loaderOperation = nil;
        }];
        [requestLV2.loader.queue lk_addOperation:requestLV2.loaderOperation request:requestLV2];
    }
    else if ([requestLV2.loader respondsToSelector:@selector(imageWithRequest:callback:)])
    {
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            if (requestLV2.isCanceled)
            {
                return;
            }
            LKDispatch(requestLV2.synchronized, requestLV2.loader.gcd_queue, ^{
                if (requestLV2.isCanceled)
                {
                    return;
                }
                requestLV2.isStarted = YES;
                [requestLV2.loader imageWithRequest:requestLV2
                                           callback:^(LKImageRequest *requestLV2, UIImage *image, float progress, NSError *error) {
                                               [self loadImageRequestFinished:requestLV2 image:image progress:progress error:error];
                                           }];
                if (!requestLV2.synchronized)
                {
                    dispatch_semaphore_wait(requestLV2.loader.semaphore, DISPATCH_TIME_FOREVER);
                }
            });
        }];
        [requestLV2.loader.queue lk_addOperation:op request:requestLV2];
    }
    else
    {
        requestLV2.error = [LKImageError errorWithCode:LKImageErrorCodeInvalidLoader];
        [requestLV2 loaderCallback:nil];
    }
}

- (void)imageWithRequest:(LKImageRequest *)requestLV1 callback:(LKImageLoaderCallback)callback
{
    requestLV1.loaderCallback = callback;
    NSOperation *op           = [NSBlockOperation blockOperationWithBlock:^{
        requestLV1.isStarted = YES;
        if (requestLV1.isCanceled)
        {
            requestLV1.isFinished = YES;
            requestLV1.error      = [LKImageError errorWithCode:LKImageErrorCodeCancel];
            [requestLV1 loaderCallback:nil];
            [requestLV1.loaderManagerCancelOperation cancel];
            requestLV1.loaderManagerCancelOperation = nil;
            return;
        }
        LKImageRequest *requestLV2 = nil;
        if (requestLV1.keyForLoader && !requestLV1.synchronized) //没有key的不合并
        {
            requestLV2 = self.requestDic[requestLV1.keyForLoader];
        }
        if (!requestLV2)
        {
            requestLV2          = [requestLV1 createSuperRequest];
            requestLV2.priority = requestLV1.priority;
            requestLV2.loader   = [self loaderForRequest:requestLV1];
            if (!requestLV2.loader)
            {
                requestLV2.error = [LKImageError errorWithDomain:LKImageErrorDomain code:LKImageErrorCodeLoaderNotFound userInfo:nil];
                [requestLV2 loaderCallback:nil];
                return;
            }

            if (requestLV1.keyForLoader && !requestLV1.synchronized) //没有key的不合并
            {
                [self.requestDic setObject:requestLV2 forKey:requestLV1.keyForLoader];
            }

            [self loadRequest:requestLV2];
        }
        else
        {

            [requestLV2 addChildRequest:requestLV1];
        }
    }];
    [self.queue lk_addOperation:op request:requestLV1];
}

- (void)preloadWithRequest:(LKImageRequest *)request
{
    [self imageWithRequest:request callback:nil];
}

- (NSMutableArray<id<LKImageLoaderProtocol>> *)loaderList
{
    if (!_loaderList)
    {
        _loaderList = [NSMutableArray array];
    }
    return _loaderList;
}

- (NSMutableDictionary *)requestDic
{
    if (!_requestDic)
    {
        _requestDic = [NSMutableDictionary dictionary];
    }
    return _requestDic;
}

- (void)cancelRequest:(LKImageRequest *)requestLV1
{
    if (!requestLV1.keyForLoader)
    {
        LKImageLogWarning(@"can not cancel.request.keyForLoad is nil");
        return;
    }
    if (requestLV1.isCanceled || requestLV1.isFinished)
    {
        return;
    }
    requestLV1.isCanceled = YES;
    lkweakify(requestLV1);
    requestLV1.loaderManagerCancelOperation = [NSBlockOperation blockOperationWithBlock:^{
        lkstrongify(requestLV1);
        requestLV1.loaderManagerCancelOperation = nil;
        if (!requestLV1.isStarted || requestLV1.isFinished)
        {
            return;
        }
        requestLV1.isFinished      = YES;
        LKImageRequest *requestLV2 = [self.requestDic objectForKey:requestLV1.keyForLoader];
        LKImageLogVerbose([NSString stringWithFormat:@"LKImageLoader cancel request:%@", requestLV2]);
        if (!requestLV2)
        {
            LKImageLogWarning(@"Cancel request failed,request not found in loader");
            return;
        }
        NSUInteger index = [requestLV2.requestList indexOfObject:requestLV1];
        if (index != NSNotFound)
        {
            requestLV1.error = [LKImageError errorWithCode:LKImageErrorCodeCancel];
            [requestLV1 loaderCallback:nil];
            [requestLV2 removeChildAtIndex:index];
            if (requestLV2.requestList.count == 0 && requestLV2.isStarted && !requestLV2.isFinished)
            {
                [self.requestDic removeObjectForKey:requestLV2.keyForLoader];
                requestLV2.isCanceled = YES;
                requestLV2.error      = [LKImageError errorWithDomain:LKImageErrorDomain code:LKImageErrorCodeCancel userInfo:nil];
                [requestLV2 loaderCallback:nil];
                if (!requestLV2.isFinished)
                {
                    if ([requestLV2.loader respondsToSelector:@selector(cancelRequest:)])
                    {
                        dispatch_async(requestLV2.loader.gcd_queue, ^{
                            if (!requestLV2.isStarted || requestLV2.isFinished)
                            {
                                return;
                            }
                            LKImageLoaderCancelResult result = [requestLV2.loader cancelRequest:requestLV2];
                            if (result == LKImageLoaderCancelResultFinishImmediately && !requestLV2.synchronized)
                            {
                                requestLV2.isFinished = YES;
                                dispatch_semaphore_signal(requestLV2.loader.semaphore);
                            }

                        });
                    }
                }
            }
        }
        else
        {
            LKImageLogWarning(@"Cancel request failed,request not found in loader");
        }
    }];
    requestLV1.isCanceled                   = YES;
    [self.queue lk_addOperation:requestLV1.loaderManagerCancelOperation request:requestLV1];
}

@end
