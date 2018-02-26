//
//  LKImageMonitor.h
//  LKImageKit
//
//  Created by lingtonke on 2018/1/4.
//  Copyright © 2018年 lingtonke. All rights reserved.
//

#import <stdatomic.h>

extern atomic_int LKImageTotalRequestCount;
extern atomic_int LKImageRunningRequestCount;
extern atomic_int LKImageCancelRequestCount;
extern atomic_int LKImageFinishRequestCount;
