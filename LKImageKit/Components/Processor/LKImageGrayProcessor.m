//
//  LKImageDefaultProcessor.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/7.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageGrayProcessor.h"
#import "LKImageUtil.h"
#import <Accelerate/Accelerate.h>

@implementation LKImageGrayProcessor

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *, NSError *))complete
{
    @autoreleasepool
    {
        int width  = input.size.width * input.scale;
        int height = input.size.height * input.scale;

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context =
            CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
        CGColorSpaceRelease(colorSpace);

        if (context == NULL)
        {
            complete(nil, [LKImageError errorWithCode:LKImageErrorCodeProcessorFailed]);
            return;
        }

        CGContextDrawImage(context, CGRectMake(0, 0, width, height), input.CGImage);
        CGImageRef image   = CGBitmapContextCreateImage(context);
        UIImage *grayImage = [UIImage imageWithCGImage:image scale:input.scale orientation:UIImageOrientationUp];
        CGImageRelease(image);
        CGContextRelease(context);

        complete(grayImage, nil);
    }
}

@end
