//
//  LKImageProcessorManager.h
//  LKImageKit
//
//  Created by lingtonke on 15/9/7.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

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
