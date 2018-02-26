//
//  LKImageSmartCache.h
//  LKImageKit
//
//  Created by lingtonke on 2017/8/14.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageCacheManager.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageSmartCache : LKImageCache

+ (instancetype)defaultCache;

- (void)addImage:(UIImage *)image key:(NSString *)key;
- (UIImage * _Nullable)imageForKey:(NSString *)key;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
