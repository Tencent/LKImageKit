//
//  LKImageCacheManager.m
//  LKImageKit
//
//  Created by lingtonke on 2017/11/17.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

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
