//
//  LKImageConfiguration.m
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageConfiguration.h"
#import "LKImageDefine.h"

#import "LKImageCacheManager.h"
#import "LKImageDecoderManager.h"
#import "LKImageLoaderManager.h"

//memory cache
#import "LKImageMemoryCache.h"
#import "LKImageSmartCache.h"

//decoder
#import "LKImageSystemDecoder.h"

//loader
#import "LKImageBundleLoader.h"
#import "LKImageLocalFileLoader.h"
#import "LKImageMemoryImageLoader.h"
#import "LKImageNetworkFileLoader.h"
#import "LKImagePhotoKitLoader.h"

@implementation LKImageConfiguration

+ (instancetype)defaultConfiguration
{
    LKImageConfiguration *config = [[LKImageConfiguration alloc] init];
    config.cacheList             = @[[LKImageSmartCache defaultCache],
        [LKImageMemoryCache defaultCache]];

    config.decoderList = @[[[LKImageSystemDecoder alloc] init]];

    config.loaderList = @[
        [[LKImageMemoryImageLoader alloc] init],
        [[LKImageNetworkFileLoader alloc] init],
        [[LKImageLocalFileLoader alloc] init],
        [[LKImagePhotoKitLoader alloc] init],
        [[LKImageBundleLoader alloc] init],
    ];

    return config;
}

@end
