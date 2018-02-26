//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
