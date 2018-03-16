//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageRequest.h"
#import "LKImageLoaderManager.h"
#import "LKImageManager.h"
#import "LKImageMonitor.h"
#import "LKImagePrivate.h"
#import "LKImageProcessorManager.h"
#import "LKImageUtil.h"
#import <objc/runtime.h>

@interface LKImageRequest ()

@property (nonatomic, assign) LKImageRequestState state;
@property (nonatomic, assign) BOOL isDecoding;
@property (nonatomic, strong) NSObject *decoderAttach;
@property (nonatomic, strong) NSOperation *imageManagerCancelOperation;
@property (nonatomic, strong) NSOperation *loaderManagerCancelOperation;
@property (nonatomic, strong) NSOperation *loaderOperation;
@property (nonatomic, strong) NSOperation *decodeOperation;
@property (nonatomic, strong) NSOperation *processorOperation;
@property (nonatomic, strong) LKImageLoader *loader;
@property (atomic, assign) BOOL isCanceled;
@property (atomic, assign) BOOL isStarted;
@property (atomic, assign) BOOL isFinished;
@property (nonatomic, strong) NSDate *requestBeginDate;
@property (nonatomic, strong) NSDate *requestEndDate;
@property (atomic, assign) float progress;
@property (atomic, strong) NSError *error;
@property (nonatomic, assign) BOOL hasCache;
@property (nonatomic, weak) LKImageRequest *superRequest;
@property (nonatomic, copy) LKImageManagerCallback managerCallback;
@property (nonatomic, copy) LKImageLoaderCallback loaderCallback;
@property (nonatomic, strong) NSMutableArray<LKImageRequest *> *requestList;
@property (nonatomic, strong) NSArray<LKImageProcessor *> *internalProcessorList;
@property (nonatomic, strong) NSArray<LKImageProcessor *> *processorList;
@property (nonatomic, assign) NSInteger loaderCallbackCount;

@end

@implementation LKImageRequest
@synthesize priority = _priority;
@synthesize progress = _progress;
@synthesize error = _error;
- (instancetype)init
{
    if (self = [super init])
    {
        self.cacheEnabled = YES;
        atomic_fetch_add(&LKImageTotalRequestCount, 1);
    }
    return self;
}

- (void)dealloc
{
    atomic_fetch_sub(&LKImageTotalRequestCount, 1);
}

- (id)copy
{
    LKImageRequest *request = [[[self class] alloc] init];
    Class cls               = [self class];
    while (cls != [NSObject class])
    {
        unsigned int numberOfIvars = 0;
        Ivar *ivars                = class_copyIvarList(cls, &numberOfIvars);
        for (const Ivar *p = ivars; p < ivars + numberOfIvars; p++)
        {
            Ivar const ivar = *p;
            NSString *key   = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (key == nil)
            {
                continue;
            }
            if ([key length] == 0)
            {
                continue;
            }

            id value = [self valueForKey:key];
            @try
            {
                [request setValue:value forKey:key];
            }
            @catch (NSException *exception)
            {
            }
        }
        if (ivars)
        {
            free(ivars);
        }

        cls = class_getSuperclass(cls);
    }
    return request;
}

- (instancetype)createSuperRequest
{
    LKImageRequest *request = [self copy];
    request.requestList     = [NSMutableArray array];
    request.managerCallback = nil;
    request.loaderCallback  = nil;
    [request addChildRequest:self];
    return request;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[LKImageRequest class]])
    {
        if ([self.identifier isEqualToString:((LKImageRequest *) object).identifier])
        {
            return YES;
        }
    }
    return NO;
}

- (void)setCustomProcessorList:(NSArray<LKImageProcessor *> *)customProcessorList
{
    _customProcessorList = customProcessorList;
    self.processorList   = [self.customProcessorList ?: [NSArray array] arrayByAddingObjectsFromArray:self.internalProcessorList];
}

- (void)setInternalProcessorList:(NSArray<LKImageProcessor *> *)internalProcessorList
{
    _internalProcessorList = internalProcessorList;
    self.processorList     = [self.customProcessorList ?: [NSArray array] arrayByAddingObjectsFromArray:self.internalProcessorList];
}

- (void)setProcessorList:(NSArray<LKImageProcessor *> *)processorList
{
    _processorList = processorList;
    [self generateIdentify];
}

- (void)setKeyForLoader:(NSString *)keyForLoader
{
    _keyForLoader = keyForLoader;
    [self generateIdentify];
}

- (NSOperationQueuePriority)priority
{
    @synchronized(self)
    {
        return _priority;
    }
}

- (void)setPriority:(NSOperationQueuePriority)priority
{
    @synchronized(self)
    {
        _priority = priority;
        self.loaderOperation.queuePriority = priority;
        self.decodeOperation.queuePriority = priority;
        self.processorOperation.queuePriority = priority;
        self.imageManagerCancelOperation.queuePriority = priority;
        self.loaderManagerCancelOperation.queuePriority = priority;
    }
    
}

- (void)generateIdentify
{
    if (self.processorList.count == 0)
    {
        self.identifier = self.keyForLoader;
    }
    self.identifier = [NSString stringWithFormat:@"%@:%@", self.keyForLoader, [LKImageProcessorManager keyForProcessorList:self.processorList]];
}

- (void)reset
{
    self.error                        = nil;
    self.progress                     = 0;
    self.isCanceled                   = NO;
    self.isStarted                    = NO;
    self.isFinished                   = NO;
    self.imageManagerCancelOperation  = nil;
    self.loaderManagerCancelOperation = nil;
    self.decodeOperation              = nil;
}

- (void)managerCallback:(UIImage *)image isFromSyncCache:(BOOL)isFromSyncCache
{
    if (self.managerCallback)
    {
        self.managerCallback(self, image, isFromSyncCache);
    }
    for (LKImageRequest *request in self.requestList)
    {
        if (request.progress >= 1 || request.error)
        {
            request.requestEndDate = [NSDate date];
        }

        if (request.managerCallback)
        {
            request.managerCallback(request, image, isFromSyncCache);
        }
    }
}

- (void)loaderCallback:(UIImage *)image
{
    if (self.loaderCallback)
    {
        self.loaderCallback(self, image);
    }
    for (LKImageRequest *request in self.requestList)
    {
        if (request.loaderCallback)
        {
            request.loaderCallback(request, image);
        }
    }
}

- (LKImageRequestState)state
{
    if (self.isFinished)
    {
        return LKImageRequestStateFinish;
    }
    else if (self.isStarted)
    {
        return LKImageRequestStateLoading;
    }
    else
    {
        return LKImageRequestStateInit;
    }
}

- (void)addChildRequest:(LKImageRequest *)request
{
    [_requestList addObject:request];
    request.superRequest = self;
    if (request.cacheEnabled)
    {
        self.cacheEnabled = YES;
    }
    if (request.supportProgressive)
    {
        self.supportProgressive = YES;
    }
    if (request.synchronized)
    {
        self.synchronized = YES;
    }
    if (request.priority > self.priority)
    {
        self.priority = request.priority;
    }
    if (CGSizeEqualToSize(self.preferredSize, CGSizeZero))
    {
        self.preferredSize = request.preferredSize;
    }
    if (request.loaderCallback)
    {
        self.loaderCallbackCount++;
    }
}

- (void)removeChildRequest:(LKImageRequest *)request
{
    NSUInteger index = [self.requestList indexOfObject:request];
    if (index != NSNotFound)
    {
        [self removeChildAtIndex:index];
    }
}

- (void)removeChildAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        LKImageRequest *request = _requestList[index];
        [_requestList removeObjectAtIndex:index];
        request.superRequest = nil;
        
        if (request.loaderCallback)
        {
            self.loaderCallbackCount--;
        }
        NSInteger priority = -1000;
        for (LKImageRequest *request in self.requestList)
        {
            if (request.priority > priority)
            {
                priority = request.priority;
            }
        }
        self.priority = priority;
    }
}

- (NSError *)error
{
    @synchronized(self)
    {
        return _error;
    }
}

- (void)setError:(NSError *)error
{
    @synchronized(self)
    {
        _error = error;
        for (LKImageRequest *request in self.requestList)
        {
            request.error = error;
        }
    }
}

- (float)progress
{
    @synchronized(self)
    {
        return _progress;
    }
}

- (void)setProgress:(float)progress
{
    @synchronized(self)
    {
        _progress = progress;
        for (LKImageRequest *request in self.requestList)
        {
            request.progress = progress;
        }
    }
}

- (NSString *)description
{
    @synchronized(self)
    {
        return [NSString stringWithFormat:@"%@ sub:%ld", [super description], (long) self.requestList.count];

    }
}

@end

@implementation LKImageURLRequest

+ (instancetype)requestWithURL:(NSString *)URL
{
    return [self requestWithURL:URL key:nil];
}

+ (instancetype)requestWithURL:(NSString *)URL key:(NSString *)key
{
    LKImageURLRequest *request = [[self alloc] init];
    request.URL                = URL;
    if (!key)
    {
        key = [LKImageUtil MD5:URL];
    }
    request.keyForLoader       = key;
    return request;
}

+ (instancetype)requestWithURL:(NSString *)URL key:(NSString *)key supportProgressive:(BOOL)supportProgressive
{
    LKImageURLRequest *request = [[self alloc] init];
    request.URL                = URL;
    if (!key)
    {
        key = [LKImageUtil MD5:URL];
    }
    request.keyForLoader       = key;
    request.supportProgressive = supportProgressive;
    return request;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ URL:%@ id:%@ loadingState:%ld", [super description], self.URL, self.identifier, (long) self.state];
}

@end

@implementation LKImageImageRequest

+ (instancetype)requestWithImage:(UIImage *)image
{
    return [self requestWithImage:image key:nil];
}

+ (instancetype)requestWithImage:(UIImage *)image key:(NSString *)key
{
    LKImageImageRequest *request = [[LKImageImageRequest alloc] init];
    request.image                = image;
    request.keyForLoader         = [NSString stringWithFormat:@"%p",image];
    request.synchronized         = YES;
    return request;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.cacheEnabled = NO;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[LKImageImageRequest class]])
    {
        LKImageImageRequest *request = (LKImageImageRequest *) object;
        return request.image == self.image;
    }
    return NO;
}

- (NSString *)identifier
{
    return [NSString stringWithFormat:@"%p", self];
}

@end
