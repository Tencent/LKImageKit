//
//  LKImageNetworkFileLoader.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/29.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageLoaderManager.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageNetworkFileLoader : LKImageLoader

@property (nonatomic) NSUInteger retryTimes;
@property (nonatomic) NSTimeInterval timeoutInterval;

+ (NSString *)cacheDirectory;
+ (NSString *)cacheFilePathForURL:(NSString *)URL;
+ (void)clearCache;

@end

NS_ASSUME_NONNULL_END
