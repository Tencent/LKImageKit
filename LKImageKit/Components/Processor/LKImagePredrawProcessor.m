//
//  LKImageDefaultProcessor.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/7.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImagePredrawProcessor.h"
#import "LKImageUtil.h"
#import <Accelerate/Accelerate.h>

@implementation LKImagePredrawProcessor

- (NSString *)identify
{
    return [NSString stringWithFormat:@"%@:%lu,%@,%@", NSStringFromClass([self class]), (unsigned long) self.scaleMode,
                     NSStringFromCGSize(self.size), NSStringFromCGPoint(self.anchorPoint)];
}

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *, NSError *))complete
{
    CGFloat scale         = [UIScreen mainScreen].scale;
    CGSize imagePixelSize = input.lk_pixelSize;
    CGSize viewPixelSize  = CGSizeMake(self.size.width * scale, self.size.height * scale);
    UIImage *newimage     = nil;
    if (imagePixelSize.width > viewPixelSize.width || imagePixelSize.height > viewPixelSize.height)
    {
        newimage             = [LKImageUtil scaleImage:input mode:self.scaleMode size:self.size anchorPoint:self.anchorPoint opaque:NO];
        newimage.lk_isScaled = YES;
    }
    else
    {
        newimage             = input;
        newimage.lk_isScaled = NO;
    }
    if (!newimage)
    {
        complete(nil, [LKImageError errorWithCode:LKImageErrorCodeProcessorFailed]);
    }
    else
    {
        complete(newimage, nil);
    }
}

@end
