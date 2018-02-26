//
//  LKImageImageIDDecoder.m
//  LKImageKit
//
//  Created by lingtonke on 2016/12/29.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageSystemDecoder.h"
#import "LKImageInfo.h"
#import "LKImagePrivate.h"
#import "LKImageUtil.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define LKImageSystemDecoderAttachKey "LKImageSystemDecoderAttachKey"
@interface LKImageSystemDecoderAttach : NSObject

@property (nonatomic, assign) CGImageSourceRef imageSource;

@end

@implementation LKImageSystemDecoderAttach

- (instancetype)init
{
    if (self = [super init])
    {
        _imageSource = CGImageSourceCreateIncremental(nil);
    }
    return self;
}

- (void)dealloc
{
    if (_imageSource)
    {
        CFRelease(_imageSource);
        _imageSource = nil;
    }
}

@end

@implementation LKImageSystemDecoder

- (UIImage *)imageFromData:(NSData *)data request:(LKImageRequest *)request error:(NSError *__autoreleasing *)error
{
    if (!data)
    {
        return nil;
    }
    LKImageSystemDecoderAttach *attach = (LKImageSystemDecoderAttach *) request.decoderAttach;
    if (!attach)
    {
        attach                = [[LKImageSystemDecoderAttach alloc] init];
        request.decoderAttach = attach;
    }
    CGImageSourceRef imageSource = attach.imageSource;
    if (request.progress == 1)
    {
        CGImageSourceUpdateData(imageSource, (CFDataRef) data, YES);
    }
    else
    {
        CGImageSourceUpdateData(imageSource, (CFDataRef) data, NO);
    }
    CFStringRef type = CGImageSourceGetType(imageSource);
    if (!type)
    {
        return nil;
    }
    
    if (UTTypeEqual(type, kUTTypeGIF))
    {
        if (request.progress < 1.0)
        {
            return nil;
        }
    }
    CFMutableDictionaryRef option = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil);
    if (request.processorList.count == 0)
    {
        CFDictionarySetValue(option, kCGImageSourceShouldCacheImmediately, kCFBooleanFalse);
    }

    NSUInteger count = CGImageSourceGetCount(imageSource);
    UIImage *result  = nil;
    if (count == 0)
    {
        result = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
    }
    else if (count == 1)
    {
        CGImageRef imageRef            = CGImageSourceCreateImageAtIndex(imageSource, 0, option);
        CFDictionaryRef cfdic          = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil);
        UIImageOrientation orientation = UIImageOrientationUp;
        if (cfdic)
        {
            NSNumber *num = (__bridge NSNumber *) CFDictionaryGetValue(cfdic, kCGImagePropertyOrientation);
            if (num != nil)
            {
                orientation = [LKImageUtil UIImageOrientationFromCGImagePropertyOrientation:(CGImagePropertyOrientation) num.integerValue];
            }

            CFRelease(cfdic);
        }

        UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:orientation];
        result         = image;
        CGImageRelease(imageRef);
    }
    else
    {
        NSMutableArray *array = [NSMutableArray array];
        for (NSUInteger i = 0; i < count; i++)
        {
            CGImageRef imageRef            = CGImageSourceCreateImageAtIndex(imageSource, i, i == 0 ? option : nil);
            UIImageOrientation orientation = UIImageOrientationUp;

            CFDictionaryRef cfdic = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil);
            if (cfdic)
            {
                NSNumber *num = (__bridge NSNumber *) CFDictionaryGetValue(cfdic, kCGImagePropertyOrientation);

                if (num != nil)
                {
                    orientation = [LKImageUtil UIImageOrientationFromCGImagePropertyOrientation:(CGImagePropertyOrientation) num.integerValue];
                }

                CFRelease(cfdic);
            }

            [array addObject:[UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:orientation]];
            CGImageRelease(imageRef);
        }
        NSTimeInterval duration = [LKImageUtil getCGImageSouceGIFFrameDelay:imageSource index:0];
        UIImage *image          = [LKImageUtil imageFromImages:array duration:duration];
        result                  = image;
    }
    CFRelease(option);
    return result;
}

@end
