//
//  LKImageDecoderManager.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/29.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageDefine.h"
#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKImageDecoder : NSObject

// 1、not supported:return nil without error
// 2、supported but error:return nil with error
// 3、success:return image without error
- (UIImage * _Nullable )imageFromData:(NSData * _Nullable)data request:(LKImageRequest * _Nullable)request error:(NSError ** _Nullable)error;

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
