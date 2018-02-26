//
//  LKImageInfo.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/8.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageInfo;
@interface UIImage (LKImageInfo)

@property (nonatomic, strong) LKImageInfo *lk_imageInfo;

//indicate image has been scaled or not.
//if true, LKImageView will not scale image.
//if false, LKImageView will scale image when display
@property (nonatomic, assign) BOOL lk_isScaled;

@end

//external infomation for UIImage
@interface LKImageInfo : NSObject

@end

@interface LKImageAnimatedImageInfo : LKImageInfo

@property (nonatomic) NSTimeInterval frameDuration;

@end

NS_ASSUME_NONNULL_END
