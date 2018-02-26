//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by geminiyao

#import "LKImagePhotoKitLoader.h"
#import <Photos/Photos.h>

@implementation LKImagePhotoKitLoader

- (BOOL)isValidRequest:(LKImageRequest *)request
{
    if ([request isKindOfClass:[LKImageURLRequest class]])
    {
        NSString *URL = ((LKImageURLRequest *) request).URL;
        return [URL containsString:@"phasset://"];
    }
    return NO;
}

- (void)imageWithRequest:(LKImageRequest *)request callback:(void (^)(LKImageRequest *, UIImage *, float, NSError *))callback
{
    if (![request isKindOfClass:[LKImageURLRequest class]])
    {
        callback(request, nil, 0, [LKImageError errorWithCode:LKImageErrorCodeInvalidLoader]);
        return;
    }
    
    NSString *URL       = ((LKImageURLRequest *) request).URL;
    NSString *phassetId = [URL componentsSeparatedByString:@"phasset://"].lastObject;
    
    if (phassetId.length == 0)
    {
        callback(request, nil, 0, [LKImageError errorWithCode:LKImageErrorCodeFileNotFound]);
        return;
    }
    
    PHFetchResult *fetchResult = nil;
    fetchResult                = [PHAsset fetchAssetsWithLocalIdentifiers:@[phassetId] options:nil];
    
    __block PHAsset *_phAsset = nil;
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *phasset, NSUInteger idx, BOOL *stop) {
        _phAsset = phasset;
        *stop    = YES;
    }];
    
    if (_phAsset == nil)
    {
        callback(request, nil, 0, [LKImageError errorWithCode:LKImageErrorCodeFileNotFound]);
        return;
    }
    
    CGSize tSize = CGSizeMake(request.preferredSize.width * 2, request.preferredSize.height * 2); // PhotoKit请求放大一倍质量.不然返回的可能会小于size造成模糊
    if (tSize.height == 0 || tSize.width == 0)
    {
        tSize = CGSizeMake(64, 64);
    }
    
    PHImageContentMode mode = PHImageContentModeAspectFill;
    if (_phAsset.pixelHeight > _phAsset.pixelWidth)
    { //因为要做上1/3对齐  所以高比宽大的图片我们按原始比例获取
        mode         = PHImageContentModeDefault;
        tSize.height = _phAsset.pixelHeight / _phAsset.pixelWidth * tSize.width;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed   = YES;
    options.resizeMode             = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode           = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.version                = PHImageRequestOptionsVersionCurrent;
    [[PHImageManager defaultManager] requestImageForAsset:_phAsset
                                               targetSize:tSize
                                              contentMode:mode
                                                  options:options
                                            resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                                                if (result)
                                                {
                                                    callback(request, result, 1.f, nil);
                                                }
                                                else
                                                {
                                                    callback(request, nil, 0, [LKImageError errorWithCode:LKImageErrorCodeInvalidFile]);
                                                }
                                            }];
}

@end
