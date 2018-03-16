//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageDefine.h"
#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageDecoderManager;

typedef NS_ENUM(NSUInteger, LKImageLoaderCancelResult) {
    LKImageLoaderCancelResultFinishImmediately,
    LKImageLoaderCancelResultWaitForCallback,
};

@protocol LKImageLoaderProtocol <NSObject>
@required

- (BOOL)isValidRequest:(LKImageRequest *_Nonnull)request;

@optional

//choose one of the interfaces
//dataWithRequest: data from loader will be decoded by LKImageDecoderManager and return a UIImage
//imageWithRequest: image from loader will skip decode stage
- (void)dataWithRequest:(LKImageRequest *)request callback:(LKImageDataCallback)callback;
- (void)imageWithRequest:(LKImageRequest *)request callback:(LKImageImageCallback)callback;

@end

@interface LKImageLoader : NSObject <LKImageLoaderProtocol>

@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;
@property (nonatomic, strong) dispatch_queue_t gcd_queue;

- (LKImageLoaderCancelResult)cancelRequest:(LKImageRequest * _Nonnull)request;

- (void)willBeRegistered;
- (void)didBeUnregistered;

@end

@interface LKImageLoaderManager : NSObject

@property (nonatomic, strong) LKImageDecoderManager *decoderManager;

+ (instancetype)defaultManager;

- (instancetype)initWithLoaderList:(NSArray<LKImageLoader *> *_Nullable)loaderList decoderList:(NSArray<LKImageDecoder *> *_Nullable)decoderList;

- (void)registerLoader:(LKImageLoader *)loader;

- (void)unregisterLoader:(LKImageLoader *)loader;

- (void)unregisterAllLoader;

- (id<LKImageLoaderProtocol> _Nullable)loaderForRequest:(LKImageRequest *)request;

- (void)imageWithRequest:(LKImageRequest*)request callback:(LKImageLoaderCallback _Nullable)callback;

- (void)preloadWithRequest:(LKImageRequest*)request callback:(LKImagePreloadCallback _Nullable)callback;

- (void)cancelRequest:(LKImageRequest *)request;

@end

NS_ASSUME_NONNULL_END
