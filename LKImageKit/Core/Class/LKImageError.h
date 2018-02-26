//
//  LKImageDefine.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

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
