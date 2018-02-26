//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageMemoryImageLoader.h"
#import "LKImageDefine.h"
#import "LKImageRequest.h"

@implementation LKImageMemoryImageLoader

- (BOOL)isValidRequest:(LKImageRequest *)request
{
    if ([request isKindOfClass:[LKImageImageRequest class]])
    {
        return YES;
    }
    return NO;
}

- (void)imageWithRequest:(LKImageRequest *)request callback:(LKImageImageCallback)callback
{
    if ([request isKindOfClass:[LKImageImageRequest class]])
    {
        LKImageImageRequest *imageRequest = (LKImageImageRequest *) request;
        callback(request, imageRequest.image, 1, nil);
    }
    else
    {
        NSError *error = [LKImageError errorWithCode:LKImageErrorCodeInvalidLoader];
        callback(request, nil, 0, error);
    }
}

@end
