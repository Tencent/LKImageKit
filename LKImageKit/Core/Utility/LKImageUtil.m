//
//  LKImageViewUtil.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/28.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageUtil.h"
#import "LKImageInfo.h"
#import <CommonCrypto/CommonCrypto.h>
#import <ImageIO/ImageIO.h>

@implementation NSTimer (LKImageKit)

+ (NSTimer *)lk_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *_Nonnull))block
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(lk_invoke:) userInfo:block repeats:repeats];
}

+ (void)lk_invoke:(NSTimer *)timer
{
    void (^block)(NSTimer *_Nonnull) = timer.userInfo;
    if (block)
    {
        block(timer);
    }
}

@end

@implementation NSOperationQueue (LKImageKit)

- (void)lk_addOperation:(NSOperation *)op request:(LKImageRequest *)request
{
    if (request.synchronized)
    {
        [op main];
    }
    else
    {
        op.queuePriority = request.priority;
        [self addOperation:op];
    }
}

@end

@implementation UIImage (LKImageKit)

- (CGSize)lk_pixelSize
{
    return CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
}

@end

@implementation LKImageUtil

+ (NSString *)MD5:(NSString *)str
{
    const char *cstr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, (CC_LONG) strlen(cstr), result);

    return [NSString stringWithFormat:
                         @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

+ (CGRect)rectFromClipSize:(CGSize)imageSize clipSize:(CGSize)clipSize scaleMode:(LKImageScaleMode)scaleMode anchorPoint:(CGPoint)anchorPoint
{
    float imageRatio = imageSize.height / imageSize.width;
    float clipRatio  = clipSize.height / clipSize.width;
    float height = 0, width = 0, x = 0, y = 0;
    if (scaleMode == LKImageScaleModeNone)
    {
        width  = imageSize.width;
        height = imageSize.height;
        x      = (clipSize.width - width) * anchorPoint.x;
        y      = (clipSize.height - height) * anchorPoint.y;
    }
    else if (scaleMode == LKImageScaleModeScaleToFill)
    {
        width  = clipSize.width;
        height = clipSize.height;
    }
    else if (scaleMode == LKImageScaleModeAspectFit)
    {
        if (imageRatio > clipRatio)
        {
            width  = clipSize.height / imageRatio;
            height = clipSize.height;
            x      = (clipSize.width - width) * anchorPoint.x;
            y      = 0;
        }
        else
        {
            width  = clipSize.width;
            height = clipSize.width * imageRatio;
            x      = 0;
            y      = (clipSize.height - height) * anchorPoint.y;
        }
    }
    else if (scaleMode == LKImageScaleModeAspectFill)
    {
        if (imageRatio < clipRatio)
        {
            width  = clipSize.height / imageRatio;
            height = clipSize.height;
            x      = (clipSize.width - width) * anchorPoint.x;
            y      = 0;
        }
        else
        {
            width  = clipSize.width;
            height = clipSize.width * imageRatio;
            x      = 0;
            y      = (clipSize.height - height) * anchorPoint.y;
        }
    }
    return CGRectMake(x, y, width, height);
}

+ (UIImage * (^)(NSDictionary *, CGSize, CGSize))intelligentFiter
{
    return ^UIImage *(NSDictionary *imageDic, CGSize requireSize, CGSize imageSizeForURL)
    {
        __block UIImage *result = nil;
        [imageDic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            CGSize size = CGSizeFromString(key);
            if (result == nil || (size.width > result.size.width && size.height > result.size.height))
            {
                result = obj;
            }
        }];
        if (!result)
        {
            return nil;
        }

        if (result.size.width >= imageSizeForURL.width && result.size.height > imageSizeForURL.height)
        {
            return result;
        }
        else if (result.size.width >= requireSize.width && result.size.height >= requireSize.height)
        {
            return result;
        }
        else
        {
            return nil;
        }
    };
}

+ (void)async:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    if (dispatch_queue_get_label(queue) == dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
    {
        block();
    }
    else
    {
        dispatch_async(queue, block);
    }
}

+ (void)sync:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    if (dispatch_queue_get_label(queue) == dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
    {
        block();
    }
    else
    {
        dispatch_sync(queue, block);
    }
}

+ (NSTimeInterval)getCGImageSouceGIFFrameDelay:(CGImageSourceRef)imageSource index:(NSUInteger)index
{
    NSTimeInterval frameDuration = 0;
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL)))
    {
        CFDictionaryRef gifProperties;
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **) &gifProperties))
        {
            const void *frameDurationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue))
            {
                frameDuration = [(__bridge NSNumber *) frameDurationValue doubleValue];
                if (frameDuration <= 0)
                {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue))
                    {
                        frameDuration = [(__bridge NSNumber *) frameDurationValue doubleValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }

    return frameDuration;
}

+ (void (^)(LKImageView *, LKImageInfo *))defaultImageInfoProcessor
{
    return ^(LKImageView *imageView, LKImageInfo *info) {
        if ([info isKindOfClass:[LKImageAnimatedImageInfo class]])
        {
            LKImageAnimatedImageInfo *aniInfo = (LKImageAnimatedImageInfo *) info;
            imageView.frameDuration           = aniInfo.frameDuration;
        }
    };
}

+ (UIImageOrientation)UIImageOrientationFromCGImagePropertyOrientation:(CGImagePropertyOrientation)cg
{
    switch (cg)
    {
        case kCGImagePropertyOrientationUp:
            return UIImageOrientationUp;
        case kCGImagePropertyOrientationUpMirrored:
            return UIImageOrientationUpMirrored;

        case kCGImagePropertyOrientationDown:
            return UIImageOrientationDown;
        case kCGImagePropertyOrientationDownMirrored:
            return UIImageOrientationDownMirrored;

        case kCGImagePropertyOrientationLeft:
            return UIImageOrientationLeft;
        case kCGImagePropertyOrientationLeftMirrored:
            return UIImageOrientationLeftMirrored;

        case kCGImagePropertyOrientationRight:
            return UIImageOrientationRight;
        case kCGImagePropertyOrientationRightMirrored:
            return UIImageOrientationRightMirrored;
    }
}

+ (UIImage *)imageFromImages:(NSArray<UIImage *> *)images duration:(double)duration
{
    if (images.count == 0)
    {
        return nil;
    }
    else if (images.count == 1)
    {
        return images.firstObject;
    }
    if (duration == 0)
    {
        duration = 1;
    }
    LKImageAnimatedImageInfo *info = [[LKImageAnimatedImageInfo alloc] init];
    info.frameDuration             = duration;
    UIImage *image                 = [UIImage animatedImageWithImages:images duration:INFINITY];
    image.lk_imageInfo             = info;
    return image;
}

+ (UIImage *)scaleImage:(UIImage *)input
                   mode:(LKImageScaleMode)mode
                   size:(CGSize)size
            anchorPoint:(CGPoint)anchorPoint
                 opaque:(BOOL)opaque
{
    CGFloat screenScale = [UIScreen mainScreen].scale;
    //convert to scale 1
    CGSize imageSize = input.lk_pixelSize;
    CGSize clipSize  = CGSizeMake(size.width * screenScale, size.height * screenScale);

    CGRect imageRect = [LKImageUtil rectFromClipSize:imageSize
                                            clipSize:clipSize
                                           scaleMode:mode
                                         anchorPoint:anchorPoint];
    BOOL hasAlpha    = NO;
    if (!opaque)
    {
        CGImageAlphaInfo info = CGImageGetAlphaInfo(input.CGImage);
        if (info == kCGImageAlphaPremultipliedLast ||
            info == kCGImageAlphaPremultipliedFirst ||
            info == kCGImageAlphaLast ||
            info == kCGImageAlphaFirst)
        {
            hasAlpha = YES;
        }
    }

    //Decode-Speed: CGContext>UIGraphic. So use CGContext first.
    CGBitmapInfo bitmapInfo    = hasAlpha ? kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst : kCGBitmapByteOrder32Host | kCGImageAlphaNoneSkipFirst;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context       = CGBitmapContextCreate(NULL, clipSize.width, clipSize.height, 8, 0, colorspace, bitmapInfo);
    CGColorSpaceRelease(colorspace);
    if (!context)
    {
        //it is thread safe
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0);

        //convert to screen scale
        CGRect rect = CGRectMake(imageRect.origin.x / screenScale, imageRect.origin.y / screenScale, imageRect.size.width / screenScale, imageRect.size.height / screenScale);
        [input drawInRect:rect];

        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    else
    {
        CGContextDrawImage(context, imageRect, input.CGImage);
        CGImageRef cgimage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        UIImage *image = [UIImage imageWithCGImage:cgimage scale:screenScale orientation:input.imageOrientation];
        CGImageRelease(cgimage);
        return image;
    }
}

@end
