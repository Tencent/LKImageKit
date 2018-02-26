//
//  LKImageMonitor.h
//  LKImageKit
//
//  Created by lingtonke on 2018/1/4.
//  Copyright © 2018年 lingtonke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageMonitor : NSObject

+ (instancetype)instance;

@property (nonatomic, assign, readonly) NSInteger totalRequestCount;
@property (nonatomic, assign, readonly) NSInteger runningRequestCount;
@property (nonatomic, assign, readonly) NSInteger cancelRequestCount;
@property (nonatomic, assign, readonly) NSInteger finishRequestCount;

@end

NS_ASSUME_NONNULL_END
