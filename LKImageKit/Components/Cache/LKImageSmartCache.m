//
//  LKImageSmartCache.m
//  LKImageKit
//
//  Created by lingtonke on 2017/8/14.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageSmartCache.h"
#import "LKImagePrivate.h"
#import <objc/runtime.h>

@interface LKImageSmartCache ()

@property (nonatomic, strong) NSMapTable<NSString *, UIImage *> *table;

@end

@implementation LKImageSmartCache

+ (instancetype)defaultCache
{
    NSAssert([NSThread isMainThread], @"must run in mainthread");
    static LKImageSmartCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LKImageSmartCache alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.table = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    }
    return self;
}

- (void)addImage:(UIImage *)image key:(NSString *)key
{
    [self.table setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return [self.table objectForKey:key];
}

- (void)clear
{
    [self.table removeAllObjects];
}

- (UIImage *)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad
{
    UIImage *image = [self imageForKey:request.identifier];
    return image;
}

- (void)cacheImage:(UIImage *)image forRequest:(LKImageRequest *)request
{
    [self addImage:image key:request.identifier];
}

@end
