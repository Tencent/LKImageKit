//
//  LKImageFileLoader.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/1.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageLocalFileLoader.h"
#import "LKImageUtil.h"

@implementation LKImageLocalFileLoader

- (BOOL)isValidRequest:(LKImageRequest *)request
{
    if ([request isKindOfClass:[LKImageURLRequest class]])
    {
        NSString *URL = ((LKImageURLRequest *) request).URL;
        return [URL hasPrefix:@"file://"];
    }
    return NO;
}

- (void)dataWithRequest:(LKImageRequest *)request callback:(LKImageDataCallback)callback
{
    if (![request isKindOfClass:[LKImageURLRequest class]])
    {
        NSError *error = [LKImageError errorWithCode:LKImageErrorCodeInvalidLoader];
        callback(request, nil, 0, error);
        return;
    }
    NSString *URL  = ((LKImageURLRequest *) request).URL;
    NSURL *fileURL = [NSURL URLWithString:URL];
    NSData *data   = [NSData dataWithContentsOfURL:fileURL];
    if (data)
    {
        callback(request, data, 1, nil);
    }
    else
    {
        NSError *error = [LKImageError errorWithCode:LKImageErrorCodeFileNotFound];
        callback(request, nil, 0, error);
    }
}

@end
