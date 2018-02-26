//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
