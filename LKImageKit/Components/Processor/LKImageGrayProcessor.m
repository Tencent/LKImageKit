//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
