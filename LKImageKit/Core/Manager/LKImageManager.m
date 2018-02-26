//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageManager.h"
#import "LKImageCacheManager.h"
#import "LKImageDecoderManager.h"
#import "LKImageDefine.h"
#import "LKImageLoaderManager.h"
#import "LKImagePrivate.h"
#import "LKImageProcessorManager.h"
#import "LKImageUtil.h"

@interface LKImageManager ()

@property (nonatomic) NSMutableDictionary<NSString *, LKImageRequest *> *requestDic;
@property (nonatomic) NSOperationQueue *queue;

@end

@implementation LKImageManager

+ (instancetype)defaultManager
{
    static LKImageManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance                  = [[self alloc] initWithConfiguration:nil];
        instance.cacheManager     = [LKImageCacheManager defaultManager];
        instance.loaderManager    = [LKImageLoaderManager defaultManager];
        instance.processorManager = [LKImageProcessorManager defaultManager];
        [instance setConfiguration:[LKImageConfiguration defaultConfiguration]];
    });
    return instance;
}

- (instancetype)init
{
    return [self initWithConfiguration:[LKImageConfiguration defaultConfiguration]];
}

- (instancetype)initWithConfiguration:(LKImageConfiguration *)configuration
{
    if (self = [super init])
    {
        self.requestDic                        = [NSMutableDictionary dictionary];
        self.queue                             = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.queue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
        self.cacheManager                      = [[LKImageCacheManager alloc] initWithCacheList:configuration.cacheList];
        self.loaderManager                     = [[LKImageLoaderManager alloc] initWithLoaderList:configuration.loaderList decoderList:configuration.decoderList];
        self.processorManager                  = [[LKImageProcessorManager alloc] init];
    }
    return self;
}

- (void)setConfiguration:(LKImageConfiguration *)configuration
{
    LKImageCacheManager *cacheManager = self.cacheManager;
    [cacheManager unregisterAllCache];
    for (LKImageCache *cache in configuration.cacheList)
    {
        [cacheManager registerCache:cache];
    }

    LKImageLoaderManager *loaderManager = self.loaderManager;
    [loaderManager unregisterAllLoader];
    for (LKImageLoader *loader in configuration.loaderList)
    {
        [loaderManager registerLoader:loader];
    }

    LKImageDecoderManager *decoderManager = self.loaderManager.decoderManager;
    [decoderManager unregisterAllDecoder];
    for (LKImageDecoder *decoder in configuration.decoderList)
    {
        [decoderManager registerDecoder:decoder];
    }
}

- (BOOL)checkAndLoadCache:(LKImageRequest *)requestLV0
{
    __block BOOL result;
    [LKImageUtil sync:dispatch_get_main_queue()
                block:^{
                    BOOL continueLoad = NO;
                    UIImage *image    = [self.cacheManager imageForRequest:requestLV0 continueLoad:&continueLoad];

                    if (image)
                    {
                        requestLV0.hasCache = YES;
                        if (!continueLoad)
                        {
                            requestLV0.progress   = 1;
                            requestLV0.isFinished = YES;
                            result                = YES;
                        }
                        else
                        {
                            result = NO;
                        }
                        [requestLV0 managerCallback:image isFromSyncCache:YES];
                    }
                    else
                    {
                        requestLV0.hasCache = NO;
                        result              = NO;
                    }
                }];
    return result;
}

- (void)requestDidFinished:(LKImageRequest *)requestLV1
{
    requestLV1.isFinished = YES;
    if (!requestLV1.synchronized)
    {
        [self.requestDic removeObjectForKey:requestLV1.identifier];
    }
    LKImageLogVerbose([NSString stringWithFormat:@"ManagerRequestDidFinish:%@", requestLV1]);
    atomic_fetch_add(&LKImageFinishRequestCount, requestLV1.requestList.count);
    atomic_fetch_sub(&LKImageRunningRequestCount, requestLV1.requestList.count);
    for (LKImageRequest *requestLV0 in requestLV1.requestList)
    {
        requestLV0.isFinished = YES;
        [requestLV0.imageManagerCancelOperation cancel];
    }
}

- (void)sendRequest:(LKImageRequest *)requestLV0
{
    [requestLV0 reset];
    requestLV0.requestBeginDate = [NSDate date];

    if (![requestLV0 isKindOfClass:[LKImageRequest class]])
    {
        return;
    }
    if (requestLV0.identifier && [self checkAndLoadCache:requestLV0])
    {
        return;
    }
    else
    {
        [self combineRequest:requestLV0];
    }
}

- (void)combineRequest:(LKImageRequest *)requestLV0
{
    requestLV0.isStarted = YES;
    atomic_fetch_add(&LKImageRunningRequestCount, 1);
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        if (requestLV0.isCanceled)
        {
            atomic_fetch_sub(&LKImageRunningRequestCount, 1);
            atomic_fetch_add(&LKImageCancelRequestCount, 1);
            requestLV0.isFinished = YES;
            requestLV0.error      = [LKImageError errorWithCode:LKImageErrorCodeCancel];
            [requestLV0 managerCallback:nil isFromSyncCache:NO];
            [requestLV0.imageManagerCancelOperation cancel];
            requestLV0.imageManagerCancelOperation = nil;
            return;
        }
        LKImageLogVerbose([NSString stringWithFormat:@"LKImageManagerProcessRequest:%@", requestLV0]);
        LKImageRequest *requestLV1 = nil;
        requestLV0.error           = nil;
        if (!requestLV0.synchronized)
        {
            requestLV1 = [self.requestDic objectForKey:requestLV0.identifier];
        }

        if (requestLV1)
        {
            LKImageLogVerbose([NSString stringWithFormat:@"ManagerRequestCombine:%@", requestLV1]);
            [requestLV1 addChildRequest:requestLV0];
            return;
        }
        else
        {
            requestLV1 = [requestLV0 createSuperRequest];
            if (!requestLV0.synchronized)
            {
                LKImageLogVerbose([NSString stringWithFormat:@"ManagerRequestCreate:%@", requestLV1]);
                [self.requestDic setObject:requestLV1 forKey:requestLV1.identifier];
            }
        }

        [self loadRequest:requestLV1];
    }];
    [self.queue lk_addOperation:op request:requestLV0];
}

- (void)loadRequest:(LKImageRequest *)requestLV1
{
    LKImageLogVerbose([NSString stringWithFormat:@"LKImageManagerLoadRequest:%@", requestLV1]);
    [self.loaderManager imageWithRequest:requestLV1
                                callback:^(LKImageRequest *requestLV1, UIImage *image) {
                                    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{

                                        if (requestLV1.error)
                                        {
                                            [self requestDidFinished:requestLV1];
                                            [requestLV1 managerCallback:nil isFromSyncCache:NO];
                                        }
                                        else
                                        {
                                            if (image)
                                            {
                                                if (requestLV1.supportProgressive || requestLV1.progress >= 1.0)
                                                {
                                                    [self processRequest:image request:requestLV1];
                                                }
                                            }
                                            if (requestLV1.progress < 1.0)
                                            {
                                                [requestLV1 managerCallback:nil isFromSyncCache:NO];
                                            }
                                        }
                                    }];
                                    [self.queue lk_addOperation:op request:requestLV1];
                                }];
}

- (void)processRequest:(UIImage *)image request:(LKImageRequest *)requestLV1
{
    LKImageLogVerbose([NSString stringWithFormat:@"LKImageManager processRequest:%@", requestLV1]);
    NSDate *date = [NSDate date];
    [[LKImageProcessorManager defaultManager] process:image
                                              request:requestLV1
                                             complete:^(UIImage *output, NSError *error) {
                                                 LKImageLogInfo([NSString stringWithFormat:@"%@ process:%f",requestLV1,[[NSDate date] timeIntervalSinceDate:date]]);
                                                 NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                                                     if (requestLV1.error || requestLV1.progress >= 1)
                                                     {
                                                         [self requestDidFinished:requestLV1];
                                                     }

                                                     if (error)
                                                     {
                                                         requestLV1.error = error;
                                                         [requestLV1 managerCallback:nil isFromSyncCache:NO];
                                                     }
                                                     else
                                                     {
                                                         if (requestLV1.progress >= 1.0)
                                                         {
                                                             if (requestLV1.cacheEnabled)
                                                             {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [self.cacheManager cacheImage:output forRequest:requestLV1];
                                                                 });
                                                             }
                                                         }

                                                         [requestLV1 managerCallback:output isFromSyncCache:NO];
                                                     }
                                                 }];
                                                 [self.queue lk_addOperation:op request:requestLV1];
                                             }];
}

- (void)cancelRequest:(LKImageRequest *)requestLV0
{
    if (!requestLV0.isStarted || requestLV0.isCanceled || requestLV0.isFinished)
    {
        return;
    }
    requestLV0.isCanceled = YES;
    [requestLV0.imageManagerCancelOperation cancel];
    lkweakify(requestLV0);
    requestLV0.imageManagerCancelOperation = [NSBlockOperation blockOperationWithBlock:^{
        lkstrongify(requestLV0);
        requestLV0.imageManagerCancelOperation = nil;
        if (!requestLV0.isStarted || requestLV0.isFinished)
        {
            return;
        }
        requestLV0.isFinished = YES;
        LKImageLogVerbose([NSString stringWithFormat:@"LKImageManager Cancel Request:%@", requestLV0]);
        LKImageRequest *requestLV1 = [self.requestDic objectForKey:requestLV0.identifier];
        if (!requestLV1)
        {
            LKImageLogWarning(@"Cancel a invalid request,request not found in manager");
            return;
        }

        requestLV0.error = [LKImageError errorWithCode:LKImageErrorCodeCancel];
        NSUInteger index = [requestLV1.requestList indexOfObject:requestLV0];
        if (index != NSNotFound)
        {
            atomic_fetch_sub(&LKImageRunningRequestCount, 1);
            atomic_fetch_add(&LKImageCancelRequestCount, 1);
            [requestLV0 managerCallback:nil isFromSyncCache:NO];
            [requestLV1 removeChildAtIndex:index];
            if (requestLV1.requestList.count == 0)
            {
                LKImageLogVerbose([NSString stringWithFormat:@"ManagerTaskDidCanceled:%@", requestLV1.identifier]);
                [self.requestDic removeObjectForKey:requestLV1.identifier];
                [self.loaderManager cancelRequest:requestLV1];
            }
        }
        else
        {
            LKImageLogWarning(@"Cancel a invalid task,request not found in manager");
            return;
        }
    }];
    requestLV0.isCanceled                  = YES;
    [self.queue lk_addOperation:requestLV0.imageManagerCancelOperation request:requestLV0];
}

@end

@implementation LKImageManager (Sugar)

- (void)sendRequest:(LKImageRequest *)request completion:(LKImageManagerCallback)callback
{
    request.managerCallback = callback;
    [self sendRequest:request];
}

@end
