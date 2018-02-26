//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
