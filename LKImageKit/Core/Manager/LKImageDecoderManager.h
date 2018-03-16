//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageDefine.h"
#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LKImageDecodeResult : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSError *error;

@end

@interface LKImageDecoder : NSObject

// 1、not supported:return nil
// 2、supported but error:return LKImageDecodeResult with error
// 3、success:return LKImageDecodeResult with image
- (LKImageDecodeResult * _Nullable )decodeResultFromData:(NSData * _Nullable)data request:(LKImageRequest * _Nullable)request;

@end

@interface LKImageDecoderManager : NSObject

@property (nonatomic, assign) BOOL continueTryToDecodeWhenFailed;

+ (instancetype)defaultManager;

- (instancetype)initWithDecoderList:(NSArray<LKImageDecoder *> *_Nullable)decoderList;

- (void)registerDecoder:(LKImageDecoder * )decoder;

- (void)unregisterDecoder:(LKImageDecoder * )decoder;

- (void)unregisterAllDecoder;

- (void)decodeImageFromData:(NSData *_Nullable)data request:(LKImageRequest * _Nullable)request complete:(LKImageDecoderCallback)complete;

@end

NS_ASSUME_NONNULL_END
