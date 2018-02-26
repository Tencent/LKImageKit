//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke


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
