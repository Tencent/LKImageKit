//
//  LKImageMemoryCache.h
//  LKImageKit
//
//  Created by batiliu
//  Modified by lingtonke
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageCacheManager.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageMemoryCache : LKImageCache

@property (nonatomic, assign) NSUInteger maxLengthForFIFO;

@property (nonatomic, assign) NSUInteger maxLengthForLRU;

@property (nonatomic, assign) NSUInteger cacheSizeLimit;

+ (instancetype)defaultCache;

- (BOOL)hasCacheWithURL:(NSString *)URL;

- (void)cacheImage:(UIImage *)image URL:(NSString *)URL;

- (UIImage * _Nullable)imageWithURL:(NSString *)URL;

- (void)clearWithURL:(NSString *)URL;

- (void)clear;

- (int64_t)cacheSize;

- (int64_t)cacheSize:(BOOL)accurate;

@end

NS_ASSUME_NONNULL_END
