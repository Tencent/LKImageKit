//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
