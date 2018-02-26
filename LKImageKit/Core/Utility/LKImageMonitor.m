//
//  LKImageMonitor.m
//  LKImageKit
//
//  Created by lingtonke on 2018/1/4.
//  Copyright © 2018年 lingtonke. All rights reserved.
//

#import "LKImageMonitor.h"
#import "LKImageLoaderManager.h"
#import "LKImageManager.h"
#import <stdatomic.h>

atomic_int LKImageTotalRequestCount;
atomic_int LKImageRunningRequestCount;
atomic_int LKImageCancelRequestCount;
atomic_int LKImageFinishRequestCount;

@implementation LKImageMonitor

+ (instancetype)instance
{
    static LKImageMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSInteger)totalRequestCount
{
    return LKImageTotalRequestCount;
}

- (NSInteger)runningRequestCount
{
    return LKImageRunningRequestCount;
}

- (NSInteger)cancelRequestCount
{
    return LKImageCancelRequestCount;
}

- (NSInteger)finishRequestCount
{
    return LKImageFinishRequestCount;
}

@end
