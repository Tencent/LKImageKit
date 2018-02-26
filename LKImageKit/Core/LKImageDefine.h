//
//  LKImageDefine.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageConfiguration.h"
#import "LKImageError.h"
#import "LKImageLogManager.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LKImageView;
@class LKImageRequest;

typedef NS_ENUM(NSUInteger, LKImageScaleMode) {
    LKImageScaleModeNone,        //no scale,influenced by anchorPoint
    LKImageScaleModeScaleToFill, //not influenced by anchorPoint
    LKImageScaleModeAspectFit,   //influenced by anchorPoint
    LKImageScaleModeAspectFill,  //influenced by anchorPoint
};

typedef void (^LKImageManagerCallback)(LKImageRequest *request, UIImage *image, BOOL isFromSyncCache);
typedef void (^LKImageLoaderCallback)(LKImageRequest *request, UIImage *image);
typedef void (^LKImageDecoderCallback)(LKImageRequest *request, UIImage *image, NSError *error);
typedef void (^LKImageImageCallback)(LKImageRequest *request, UIImage *image, float progress, NSError *error);
typedef void (^LKImageDataCallback)(LKImageRequest *request, NSData *data, float progress, NSError *error);
