//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageView;
@class LKImageRequest;
@class LKImageInfo;
@interface LKImageError : NSError

+ (NSString *)descriptionForCode:(NSInteger)code;

+ (instancetype)errorWithCode:(NSInteger)code;

- (instancetype)initWithCode:(NSInteger)code;

@end

extern NSString *const LKImageErrorDomain;

typedef NS_ENUM(NSInteger, LKImageErrorCode) {
    LKImageErrorCodeUnknow              = -1,
    LKImageErrorCodeCancel              = -999,
    LKImageErrorCodeInvalidRequest      = -2,
    LKImageErrorCodeInvalidLoader       = -3,
    LKImageErrorCodeLoaderNotFound      = -4,
    LKImageErrorCodeFileNotFound        = -5,
    LKImageErrorCodeInvalidFile         = -6,
    LKImageErrorCodeInvalidDecoder      = -7,
    LKImageErrorCodeDecoderNotFound     = -8,
    LKImageErrorCodeDecodeFailed        = -9,
    LKImageErrorCodeDataEmpty           = -10,
    LKImageErrorCodeProcessorFailed     = -11,
    LKImageErrorCodeLoaderReturnNoImage = -12,
    LKImageErrorCodeRequestIsDecoding   = -13,
};

NS_ASSUME_NONNULL_END
