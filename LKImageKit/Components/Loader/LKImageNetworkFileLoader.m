//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageNetworkFileLoader.h"
#import "LKImagePrivate.h"
#import "LKImageUtil.h"
#import <objc/runtime.h>

@interface LKImageNetworkFileLoaderTask : NSObject

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) LKImageRequest *request;
@property (nonatomic, copy) LKImageDataCallback callback;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSUInteger totalLength;
@property (nonatomic, assign) NSUInteger retryTimes;

@end

@implementation LKImageNetworkFileLoaderTask

@end

@interface LKImageNetworkFileLoader () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSOperationQueue *sessionQueue;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMapTable *reqTable;
@property (nonatomic, strong) NSMapTable *taskTable;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation LKImageNetworkFileLoader

- (instancetype)init
{
    if (self = [super init])
    {
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (BOOL)isValidRequest:(LKImageRequest *)request
{
    if ([request isKindOfClass:[LKImageURLRequest class]])
    {
        NSString *URL = ((LKImageURLRequest *) request).URL;
        return [URL hasPrefix:@"http://"] || [URL hasPrefix:@"https://"];
    }
    return NO;
}

- (void)willBeRegistered
{
    self.reqTable                                 = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    self.taskTable                                = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    self.sessionQueue                             = [[NSOperationQueue alloc] init];
    self.sessionQueue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
    self.sessionQueue.maxConcurrentOperationCount = 20;
    self.session                                  = [NSURLSession
                                                     sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                     delegateQueue:self.sessionQueue];
    self.timeoutInterval                          = 30;
    self.retryTimes                               = 3;
    self.maxConcurrentOperationCount              = 20;
}

- (void)didBeUnregistered
{
    [self.session invalidateAndCancel];
    self.session = nil;
    self.reqTable = nil;
    self.taskTable = nil;
}

- (void)dealloc
{
    
}

- (void)dataWithRequest:(LKImageRequest *)request callback:(LKImageDataCallback)callback
{
    if (![request isKindOfClass:[LKImageURLRequest class]])
    {
        NSError *error = [LKImageError errorWithCode:LKImageErrorCodeInvalidLoader];
        callback(request, nil, 0, error);
        return;
    }
    LKImageURLRequest *URLRequest = (LKImageURLRequest *) request;
    NSString *URL                 = URLRequest.URL;
    URL                           = [URL stringByAppendingString:@"?tp=sharp"];
    NSURL *fileURL                = [NSURL fileURLWithPath:[LKImageNetworkFileLoader cacheFilePathForURL:request.keyForLoader]];
    NSData *data                  = [NSData dataWithContentsOfURL:fileURL];
    if (data)
    {
        callback(request, data, 1, nil);
        return;
    }
    NSURLRequest *URLrequest   = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:self.timeoutInterval];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:URLrequest];
    
    LKImageNetworkFileLoaderTask *loaderTask = [[LKImageNetworkFileLoaderTask alloc] init];
    loaderTask.task                          = task;
    loaderTask.callback                      = callback;
    loaderTask.data                          = [NSMutableData data];
    loaderTask.request                       = request;
    [self.lock lock];
    [self.reqTable setObject:loaderTask forKey:request.keyForLoader];
    [self.taskTable setObject:loaderTask forKey:@(task.taskIdentifier)];
    [self.lock unlock];
    
    [task resume];
}

- (LKImageLoaderCancelResult)cancelRequest:(LKImageRequest *)request
{
    [self.lock lock];
    LKImageNetworkFileLoaderTask *loaderTask = [self.reqTable objectForKey:request.keyForLoader];
    [self.lock unlock];
    NSURLSessionTask *task                   = loaderTask.task;
    if (task)
    {
        [task cancel];
    }
    return LKImageLoaderCancelResultWaitForCallback;
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    self.reqTable = nil;
    self.taskTable = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *rsp = (NSHTTPURLResponse *) response;
        NSString *num          = rsp.allHeaderFields[@"Content-Length"];
        if ([num isKindOfClass:[NSString class]])
        {
            [self.lock lock];
            LKImageNetworkFileLoaderTask *loaderTask = [self.taskTable objectForKey:@(dataTask.taskIdentifier)];
            [self.lock unlock];
            loaderTask.totalLength                   = [num integerValue];
        }
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.lock lock];
    LKImageNetworkFileLoaderTask *loaderTask = [self.taskTable objectForKey:@(dataTask.taskIdentifier)];
    [self.lock unlock];
    LKImageDataCallback callback             = loaderTask.callback;
    NSMutableData *recvdata                  = loaderTask.data;
    LKImageRequest *request                  = loaderTask.request;
    [recvdata appendData:data];
    if (callback)
    {
        float progress = recvdata.length / (float) loaderTask.totalLength;
        if (progress > 1)
        {
            progress = 1;
        }
        if (isinf(progress))
        {
            progress = 0;
        }
        if (progress < 1)
        {
            callback(request, recvdata, progress, nil);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.lock lock];
    LKImageNetworkFileLoaderTask *loaderTask = [self.taskTable objectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
    if (!loaderTask)
    {
        return;
    }

    LKImageDataCallback callback = loaderTask.callback;
    NSMutableData *data          = loaderTask.data;
    LKImageRequest *request      = loaderTask.request;
    [self.lock lock];
    [self.reqTable removeObjectForKey:request.keyForLoader];
    [self.taskTable removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
    NSURL *fileURL = [NSURL fileURLWithPath:[LKImageNetworkFileLoader cacheFilePathForURL:request.keyForLoader]];
    if (error)
    {
        if (error.code != NSURLErrorCancelled)
        {
            if (loaderTask.retryTimes < self.retryTimes)
            {
                loaderTask.retryTimes++;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.gcd_queue, ^{
                    [self dataWithRequest:loaderTask.request callback:callback];
                });
            }
            else
            {
                if (callback)
                {
                    callback(request, nil, 1, error);
                }
            }
            
        }
        else
        {
            if (callback)
            {
                callback(request, nil, 1, error);
            }
        }
    }
    else
    {
        [data writeToURL:fileURL atomically:YES];
        if (callback)
        {
            callback(request, data, 1, error);
        }
    }
}

+ (NSString *)cacheDirectory
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
        stringByAppendingPathComponent:@"images/"];

    return path;
}

+ (NSString *)cacheFilePathForURL:(NSString *)URL
{
    NSString *path = [self cacheDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:true
                                               attributes:nil
                                                    error:nil];
    return [path stringByAppendingPathComponent:[LKImageUtil MD5:URL]];
}

+ (void)clearCache
{
    [NSFileManager.defaultManager removeItemAtPath:[self cacheDirectory] error:nil];
}

@end
