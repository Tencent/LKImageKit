//
//  ExampleFastFileCache.h
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/29.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import <LKImageKit/LKImageKit.h>

@interface ExampleFastFileCache : LKImageCache

+ (instancetype)instance;

@property (nonatomic, strong) NSCache *cache;

@end
