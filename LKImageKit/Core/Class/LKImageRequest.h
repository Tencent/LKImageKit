//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageDefine.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageLoader;
@class LKImageProcessor;
typedef NS_ENUM(NSUInteger, LKImageRequestState) {
    LKImageRequestStateInit,
    LKImageRequestStateLoading,
    LKImageRequestStateFinish,
};

@interface LKImageRequest : NSObject<NSCopying>

//Identify of request. Indicate requests is equal or not. Always use in memory cache
@property (nonatomic, strong) NSString *identifier;
//Key for loading file. Indicate requests's data is from whitch source. Always use in disk cache
@property (nonatomic, strong) NSString *keyForLoader;

//Support progressive or not.
//If true, data/image from loader will always be decoded and display.
//If false, data/image from loader will be decoded and display only if progress is 1.
@property (nonatomic, assign) BOOL supportProgressive;

@property (nonatomic, assign, readonly) LKImageRequestState state;

//Default is 0
@property (atomic, assign) NSOperationQueuePriority priority;

//PreferredSize default is equal to LKImageView's size if using LKImageView.
@property (nonatomic, assign) CGSize preferredSize;

//Indicate the image should save in cache or not
@property (nonatomic, assign) BOOL cacheEnabled;

//Processor will progress the image before display
@property (nonatomic, strong) NSArray<LKImageProcessor *> *customProcessorList;

//Indicate the request is synchronized or asynchronized.
//If true, all operation for request will be synchronized.
//If false, cache is synchronized but LKImageManager/LKImageProcessorManager/LKImageLoaderManager has its own queue.
@property (nonatomic, assign) BOOL synchronized;

@property (atomic, assign, readonly) float progress;
@property (atomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) BOOL hasCache;
@property (nonatomic, strong, readonly) LKImageDecoder *decoder;
@property (nonatomic, assign, readonly) float decodeDuration;
@property (nonatomic, strong, readonly) NSString *imageType;
@property (nonatomic, strong, readonly) LKImageLoader *loader;
@property (nonatomic, assign, readonly) float loadDuration;
@property (nonatomic, assign, readonly) NSInteger level;


@end

@interface LKImageURLRequest : LKImageRequest

@property (nonatomic, strong) NSString * URL;

+ (nonnull instancetype)requestWithURL:(NSString *)URL;
+ (nonnull instancetype)requestWithURL:(NSString *)URL key:(NSString * _Nullable)key;
+ (nonnull instancetype)requestWithURL:(NSString *)URL key:(NSString * _Nullable)key supportProgressive:(BOOL)supportProgressive;

@end

@interface LKImageImageRequest : LKImageRequest

@property (nonatomic, strong) UIImage * _Nullable image;

+ (nonnull instancetype)requestWithImage:(UIImage *)image;
+ (nonnull instancetype)requestWithImage:(UIImage *)image key:(NSString * _Nullable)key;

@end

NS_ASSUME_NONNULL_END
