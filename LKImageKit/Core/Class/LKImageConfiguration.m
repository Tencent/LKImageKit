//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
