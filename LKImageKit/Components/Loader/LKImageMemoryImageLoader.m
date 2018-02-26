//
//  LKImageMemoryImageLoader.m
//  LKImageKit
//
//  Created by lingtonke on 2016/12/29.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

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
