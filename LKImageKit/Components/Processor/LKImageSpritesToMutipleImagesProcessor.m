//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
    if (!context)
    {
        complete(nil, [LKImageError errorWithCode:LKImageErrorCodeProcessorFailed]);
        return;
    }
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
