//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageProcessor : NSObject

@property (nonatomic, strong) LKImageProcessor *nextProcessor;

//Identyfy of the processor. Return NSStringFromClass([self class]) by default.
- (NSString *)identify;

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *output, NSError *error))complete;

@end

@interface LKImageProcessorManager : NSObject

+ (instancetype)defaultManager;
- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *output, NSError *error))complete;
+ (NSString *)keyForProcessorList:(NSArray *)processorList;

@end

NS_ASSUME_NONNULL_END
