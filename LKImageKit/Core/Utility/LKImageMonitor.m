//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageMonitor.h"
#import "LKImageLoaderManager.h"
#import "LKImageManager.h"
#import <stdatomic.h>
#import "LKImageDecoderManager.h"
#import "LKImageRequest.h"

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

- (void)requestDidFinishLoad:(LKImageRequest*)request
{
    if ([self.delegate respondsToSelector:@selector(requestDidFinishLoad:)])
    {
        [self.delegate requestDidFinishLoad:request];
    }
}

- (void)requestDidFinishDecode:(LKImageRequest*)request
{
    if ([self.delegate respondsToSelector:@selector(requestDidFinishDecode:)])
    {
        [self.delegate requestDidFinishDecode:request];
    }
}

@end
