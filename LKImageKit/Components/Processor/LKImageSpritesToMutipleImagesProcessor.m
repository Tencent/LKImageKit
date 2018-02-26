//
//  LKImageDefaultProcessor.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/7.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageSpritesToMutipleImagesProcessor.h"
#import "LKImageUtil.h"

@implementation LKImageSpritesToMutipleImagesProcessor

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *, NSError *))complete
{
    NSMutableArray *array      = [NSMutableArray array];
    CGBitmapInfo bitmapInfo    = kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst;
    CGSize imageSize           = CGSizeMake(input.size.width * input.scale, input.size.height * input.scale);
    CGRect imageRect           = CGRectMake(0, self.spriteSize.height - imageSize.height, imageSize.width, imageSize.height);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context       = CGBitmapContextCreate(NULL, self.spriteSize.width, self.spriteSize.height, 8, 0, colorspace, bitmapInfo);
    CGColorSpaceRelease(colorspace);
    do
    {
        CGContextDrawImage(context, imageRect, input.CGImage);
        CGImageRef cgimage = CGBitmapContextCreateImage(context);
        UIImage *image     = [UIImage imageWithCGImage:cgimage];
        CGImageRelease(cgimage);
        if (image)
        {
            [array addObject:image];
        }
        imageRect.origin.x -= self.spriteSize.width;
        if (self.spriteSize.width - imageRect.origin.x > imageSize.width)
        {
            imageRect.origin.x = 0;
            imageRect.origin.y += self.spriteSize.height;
        }
    } while (imageRect.origin.y <= 0);
    UIImage *image = [LKImageUtil imageFromImages:array duration:0];
    complete(image, nil);
    CFRelease(context);
}

@end
