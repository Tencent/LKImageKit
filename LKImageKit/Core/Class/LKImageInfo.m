//
//  LKImageInfo.m
//  LKImageKit
//
//  Created by lingtonke on 2016/12/8.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageInfo.h"
#include <objc/runtime.h>

@implementation UIImage (LKImageInfo)

- (void)setLk_imageInfo:(LKImageInfo *)imageInfo
{
    objc_setAssociatedObject(self, @selector(setLk_imageInfo:), imageInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LKImageInfo *)lk_imageInfo
{
    return objc_getAssociatedObject(self, @selector(setLk_imageInfo:));
}

- (void)setLk_isScaled:(BOOL)lk_isScaled
{
    objc_setAssociatedObject(self, @selector(setLk_isScaled:), @(lk_isScaled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lk_isScaled
{
    return [objc_getAssociatedObject(self, @selector(setLk_isScaled:)) boolValue];
}

@end

@implementation LKImageInfo

@end

@implementation LKImageAnimatedImageInfo

@end
