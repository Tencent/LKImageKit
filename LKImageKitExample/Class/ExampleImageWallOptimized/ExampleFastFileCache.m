//
//  ExampleFastFileCache.m
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/29.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import "ExampleFastFileCache.h"
#import "ExampleImageURLRequest.h"

@implementation ExampleFastFileCache

+ (instancetype)instance
{
    static ExampleFastFileCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.cache                = [[NSCache alloc] init];
        self.cache.totalCostLimit = 1024 * 1024 * 100;
    }
    return self;
}

- (UIImage *)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad
{
    if ([request isKindOfClass:[ExampleImageURLRequest class]])
    {
        ExampleImageURLRequest *req = (ExampleImageURLRequest *) request;
        if (req.dataCacheEnabled)
        {
            NSData *data = [self.cache objectForKey:req.keyForLoader];
            if (data)
            {
                return [UIImage imageWithData:data];
            }
        }
    }
    return nil;
}

@end
