//
//  LKImageCacheManager.h
//  LKImageKit
//
//  Created by lingtonke on 2017/11/17.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageDefine.h"
#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageCache : NSObject

- (UIImage *_Nullable)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad;
- (void)cacheImage:(UIImage *)image forRequest:(LKImageRequest *)request;
- (void)clear;

@end

@interface LKImageCacheManager : NSObject

+ (instancetype)defaultManager;

- (instancetype)initWithCacheList:(NSArray<LKImageCache *> *)cacheList;

- (void)registerCache:(LKImageCache *)cache;

- (void)unregisterCache:(LKImageCache *)cache;

- (void)unregisterAllCache;

- (UIImage *_Nullable)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad;

- (void)cacheImage:(UIImage *)image forRequest:(LKImageRequest *)request;

- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
