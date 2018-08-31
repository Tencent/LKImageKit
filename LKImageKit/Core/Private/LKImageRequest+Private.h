//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageRequest.h"

@interface LKImageRequest (Private)

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *keyForLoader;
@property (atomic, assign) BOOL isDecoding;
@property (nonatomic, strong) NSObject *decoderAttach;
@property (nonatomic, strong) NSOperation *imageManagerCancelOperation;
@property (nonatomic, strong) NSOperation *loaderManagerCancelOperation;
@property (nonatomic, strong) NSOperation *loaderOperation;
@property (nonatomic, strong) NSOperation *decodeOperation;
@property (nonatomic, strong) NSOperation *processorOperation;
@property (nonatomic, strong) LKImageLoader *loader;
@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, strong) NSDate *requestBeginDate;
@property (nonatomic, strong) NSDate *requestEndDate;
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL hasCache;
@property (nonatomic, strong) LKImageDecoder *decoder;
@property (nonatomic, assign) float decodeDuration;
@property (nonatomic, strong) NSString *imageType;
@property (nonatomic, assign) float loadDuration;
@property (nonatomic, weak) LKImageRequest *superRequest;
@property (nonatomic, copy) LKImageManagerCallback managerCallback;
@property (nonatomic, copy) LKImageLoaderCallback loaderCallback;
@property (nonatomic, copy) LKImagePreloadCallback preloadCallback;
@property (nonatomic, strong) NSMutableArray<LKImageRequest *> *requestList;
@property (nonatomic, strong) NSArray<LKImageProcessor *> *internalProcessorList;
@property (nonatomic, strong) NSArray<LKImageProcessor *> *processorList;
@property (nonatomic, assign) NSInteger loaderCallbackCount;
@property (nonatomic, assign) NSInteger level;

- (BOOL)canCancel;

- (void)invokePreloadCallback;
- (void)managerCallback:(UIImage *)image isFromSyncCache:(BOOL)isFromSyncCache;
- (void)loaderCallback:(UIImage *)image;
- (void)reset;

- (instancetype)createSuperRequest;
- (void)addChildRequest:(LKImageRequest *)request;
- (void)removeChildRequest:(LKImageRequest *)request;
- (void)removeChildAtIndex:(NSUInteger)index;

@end
