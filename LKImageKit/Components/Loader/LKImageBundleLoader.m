//
//  LKImageBundleLoader.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/9.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageBundleLoader.h"
#import "LKImageDefine.h"
#import "LKImageRequest.h"
#import "LKImageUtil.h"

@implementation LKImageBundleLoader

- (BOOL)isValidRequest:(LKImageRequest *)request
{
    if ([request isKindOfClass:[LKImageURLRequest class]])
    {
        NSString *URL = ((LKImageURLRequest *) request).URL;
        if (URL.length > 0)
        {
            return YES;
        }
    }
    return NO;
}

- (void)imageWithRequest:(LKImageRequest *)request callback:(LKImageImageCallback)callback
{
    if ([request isKindOfClass:[LKImageURLRequest class]])
    {
        NSString *URL       = ((LKImageURLRequest *) request).URL;
        NSString *extension = URL.pathExtension;
        UIImage *image      = nil;
        if (extension.length>0)
        {
            NSString *fullname  = [URL lastPathComponent];
            NSString *name      = [fullname stringByDeletingPathExtension];
            NSString *path      = [[NSBundle mainBundle] pathForResource:name ofType:extension];
            image               = [UIImage imageWithContentsOfFile:path];
            
        }
        else
        {
            image = [UIImage imageNamed:URL];
        }
        
        if (!image)
        {
            NSError *error = [LKImageError errorWithCode:LKImageErrorCodeFileNotFound];
            callback(request, nil, 0, error);
        }
        else
        {
            callback(request, image, 1, nil);
        }
        
    }
    else
    {
        NSError *error = [LKImageError errorWithCode:LKImageErrorCodeInvalidLoader];
        callback(request, nil, 0, error);
    }
}

@end
