//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
