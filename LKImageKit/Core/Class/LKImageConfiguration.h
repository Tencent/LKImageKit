//
//  LKImageConfig.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageCache;
@class LKImageDecoder;
@class LKImageLoader;
@interface LKImageConfiguration : NSObject

+ (instancetype)defaultConfiguration;

@property (nonatomic, strong) NSArray<LKImageCache *> *cacheList;

@property (nonatomic, strong) NSArray<LKImageDecoder *> *decoderList;

@property (nonatomic, strong) NSArray<LKImageLoader *> *loaderList;

@end

NS_ASSUME_NONNULL_END
