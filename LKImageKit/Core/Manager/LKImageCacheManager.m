//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageCacheManager.h"

@implementation LKImageCache

- (UIImage *)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad
{
    return nil;
}

- (void)cacheImage:(UIImage *)image forRequest:(LKImageRequest *)request
{
    
}

- (void)clear
{
    
}

@end

@interface LKImageCacheManager ()

@property (nonatomic, strong) NSMutableArray<LKImageCache *> *cacheList;

@end

@implementation LKImageCacheManager

+ (instancetype)defaultManager
{
    NSAssert([NSThread isMainThread], @"LKImageCache is not running on Main Thread!");

    static LKImageCacheManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)initWithCacheList:(NSArray<LKImageCache *> *)cacheList
{
    if (self = [super init])
    {
        self.cacheList = [NSMutableArray arrayWithArray:cacheList];
    }
    return self;
}

- (void)registerCache:(LKImageCache *)cache
{
    [self.cacheList addObject:cache];
}

- (void)unregisterCache:(LKImageCache *)cache
{
    [self.cacheList removeObject:cache];
}

- (void)unregisterAllCache
{
    [self.cacheList removeAllObjects];
}

- (UIImage *)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad
{
    UIImage *image = nil;
    for (LKImageCache *cache in self.cacheList)
    {
        image = [cache imageForRequest:request continueLoad:continueLoad];
        if (image)
        {
            break;
        }
    }
    return image;
}

- (void)cacheImage:(UIImage *)image forRequest:(LKImageRequest *)request
{
    for (LKImageCache *cache in self.cacheList)
    {
        [cache cacheImage:image forRequest:request];
    }
}

- (NSMutableArray<LKImageCache *> *)cacheList
{
    if (!_cacheList)
    {
        _cacheList = [NSMutableArray array];
    }
    return _cacheList;
}

- (void)clearAll
{
    for (LKImageCache *cache in self.cacheList)
    {
        [cache clear];
    }
}

@end
