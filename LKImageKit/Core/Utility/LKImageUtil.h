
//
//  LKImageViewUtil.h
//  LKImageKit
//
//  Created by lingtonke on 15/9/28.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageDefine.h"
#import "LKImageView.h"
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

#define lkweakify(VAR) __weak __typeof__(VAR)(VAR##_weak_) = (VAR)
#define lkstrongify(VAR) __strong __typeof__(VAR) VAR = (VAR##_weak_)

@interface NSTimer (LKImageKit)

+ (nonnull NSTimer *)lk_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(nonnull void (^)(NSTimer *_Nonnull))block;

@end

@interface NSOperationQueue (LKImageKit)

- (void)lk_addOperation:(NSOperation *_Nullable)op request:(LKImageRequest *_Nonnull)request;

@end

@interface UIImage (LKImageKit)

- (CGSize)lk_pixelSize;

@end

inline static void LKDispatch(BOOL sync, dispatch_queue_t _Nonnull queue, dispatch_block_t _Nonnull block)
{
    if (sync)
    {
        block();
    }
    else
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
}

@interface LKImageUtil : NSObject

+ (nullable NSString *)MD5:(nullable NSString *)str;

+ (CGRect)rectFromClipSize:(CGSize)interalSize
                  clipSize:(CGSize)clipSize
                 scaleMode:(LKImageScaleMode)scaleMode
               anchorPoint:(CGPoint)anchorPoint;

+ (void)async:(nullable dispatch_queue_t)queue block:(nonnull dispatch_block_t)block;

+ (void)sync:(nullable dispatch_queue_t)queue block:(nonnull dispatch_block_t)block;

+ (NSTimeInterval)getCGImageSouceGIFFrameDelay:(nonnull CGImageSourceRef)imageSource index:(NSUInteger)index;

+ (UIImageOrientation)UIImageOrientationFromCGImagePropertyOrientation:(CGImagePropertyOrientation)cg;

+ (nullable UIImage *)imageFromImages:(nullable NSArray<UIImage *> *)images duration:(double)duration;

+ (nullable UIImage *)scaleImage:(nonnull UIImage *)input
                            mode:(LKImageScaleMode)mode
                            size:(CGSize)size
                     anchorPoint:(CGPoint)anchorPoint
                          opaque:(BOOL)opaque;

@end
