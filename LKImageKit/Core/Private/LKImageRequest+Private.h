//
//  LKImageRequest.h
//  LKImageKit
//
//  Created by lingtonke on 15/11/26.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageRequest.h"

@interface LKImageRequest (Private)

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *keyForLoader;
@property (nonatomic, assign) BOOL isDecoding;
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
@property (nonatomic, weak) LKImageRequest *superRequest;
@property (nonatomic, copy) LKImageManagerCallback managerCallback;
@property (nonatomic, copy) LKImageLoaderCallback loaderCallback;
@property (nonatomic, strong) NSMutableArray<LKImageRequest *> *requestList;
@property (nonatomic, strong) NSArray<LKImageProcessor *> *internalProcessorList;
@property (nonatomic, strong) NSArray<LKImageProcessor *> *processorList;
@property (nonatomic, assign) NSInteger loaderCallbackCount;

- (BOOL)canCancel;

- (void)managerCallback:(UIImage *)image isFromSyncCache:(BOOL)isFromSyncCache;
- (void)loaderCallback:(UIImage *)image;
- (void)reset;

- (instancetype)createSuperRequest;
- (void)addChildRequest:(LKImageRequest *)request;
- (void)removeChildRequest:(LKImageRequest *)request;
- (void)removeChildAtIndex:(NSUInteger)index;

@end
