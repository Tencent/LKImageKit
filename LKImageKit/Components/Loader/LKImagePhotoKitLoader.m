//
//  LKImagePhotoKitLoader.m
//  LKImageKit
//
//  Created by geminiyao on 16/5/17.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

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
