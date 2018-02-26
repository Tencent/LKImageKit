//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
