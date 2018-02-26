//
//  LKImageManager.h
//  LKImageKit
//
//  Created by lingtonke on 15/9/10.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageRequest.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageCacheManager;
@class LKImageLoaderManager;
@class LKImageProcessorManager;
@interface LKImageManager : NSObject

@property (nonatomic,strong) LKImageCacheManager *cacheManager;
@property (nonatomic,strong) LKImageLoaderManager *loaderManager;
@property (nonatomic,strong) LKImageProcessorManager *processorManager;

+ (instancetype)defaultManager;
- (instancetype)initWithConfiguration:(LKImageConfiguration *_Nullable)configuration;
- (void)setConfiguration:(LKImageConfiguration *_Nullable)configuration;

- (void)sendRequest:(LKImageRequest *)request;
- (void)cancelRequest:(LKImageRequest *)request;

@end

@interface LKImageManager (Sugar)

- (void)sendRequest:(LKImageRequest *)request completion:(LKImageManagerCallback)callback;

@end

NS_ASSUME_NONNULL_END
