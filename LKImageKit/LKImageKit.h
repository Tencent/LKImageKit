//
//  LKImageKit.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LKImageConfiguration.h"
#import "LKImageDefine.h"
#import "LKImageInfo.h"
#import "LKImageMonitor.h"
#import "LKImageRequest.h"
#import "LKImageUtil.h"

//view
#import "LKImageView.h"

//manager
#import "LKImageCacheManager.h"
#import "LKImageDecoderManager.h"
#import "LKImageLoaderManager.h"
#import "LKImageLogManager.h"
#import "LKImageManager.h"
#import "LKImageProcessorManager.h"

//cache
#import "LKImageMemoryCache.h"
#import "LKImageSmartCache.h"

//processor
#import "LKImageBlurProcessor.h"
#import "LKImageGrayProcessor.h"
#import "LKImagePredrawProcessor.h"
#import "LKImageSpritesToMutipleImagesProcessor.h"

//decoder
#import "LKImageSystemDecoder.h"

//loader
#import "LKImageBundleLoader.h"
#import "LKImageLocalFileLoader.h"
#import "LKImageMemoryImageLoader.h"
#import "LKImageNetworkFileLoader.h"
#import "LKImagePhotoKitLoader.h"
