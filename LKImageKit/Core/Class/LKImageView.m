//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageView.h"
#import "LKImageBlurProcessor.h"
#import "LKImageDefine.h"
#import "LKImageGrayProcessor.h"
#import "LKImageManager.h"
#import "LKImagePredrawProcessor.h"
#import "LKImagePrivate.h"
#import "LKImageProcessorManager.h"
#import "LKImageUtil.h"
#import <objc/runtime.h>

@implementation LKImageViewEffect

- (instancetype)init
{
    if (self = [super init])
    {
        self.blurRadius = 0.3;
    }
    return self;
}

- (NSArray<LKImageProcessor *> *)processorList
{
    NSMutableArray *processorList = [NSMutableArray array];

    if (self.blurEnabled)
    {
        LKImageBlurProcessor *p = [[LKImageBlurProcessor alloc] init];
        p.blurRadius            = self.blurRadius;
        p.blurTintColor         = self.blurTintColor;
        [processorList addObject:p];
    }
    if (self.grayEnabled)
    {
        LKImageGrayProcessor *p = [[LKImageGrayProcessor alloc] init];
        [processorList addObject:p];
    }

    return processorList;
}

@end

@interface LKImageView ()

@property (nonatomic, assign) CGSize oldSize;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger animationIndex;
@property (nonatomic, strong) LKImageRequest *currentRequest;

@end

@implementation LKImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    [self.imageManager cancelRequest:self.request];
    self.delegate = nil;
}

- (void)setup
{
    self.imageView                   = [[UIImageView alloc] init];
    self.imageView.backgroundColor   = [UIColor clearColor];
    self.imageView.clipsToBounds     = YES;
    self.imageView.animationDuration = 1.0 / 30.0;
    self.scaleMode                   = LKImageScaleModeAspectFill;
    self.anchorPoint                 = CGPointMake(0.5, 0.5);
    self.predrawEnabled              = YES;
    [self addSubview:self.imageView];
    self.clipsToBounds     = YES;
    self.opaque            = YES;
    self.layer.opaque      = YES;
    self.fadeMode          = LKImageViewFadeModeAfterLoad;
    self.shouldAutoPlay    = YES;
    self.backgroundColor   = [UIColor clearColor];
    _effect                = [[LKImageViewEffect alloc] init];
    self.delayLoadingImage = YES;
    self.imageManager      = [LKImageManager defaultManager];
}


- (void)layoutImageView
{
    if (!self.presentationImage)
    {
        return;
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.presentationImage.lk_isScaled)
    {
        self.imageView.frame = self.bounds;
        return;
    }

    CGSize size = CGSizeMake(self.presentationImage.size.width * self.presentationImage.scale / [UIScreen mainScreen].scale, self.presentationImage.size.height * self.presentationImage.scale / [UIScreen mainScreen].scale);
    CGRect rect = [LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];

    self.imageView.frame = rect;
}

- (CGSize)size
{
    return self.bounds.size;
}

- (void)dealWithRequest:(LKImageRequest *)request
{
    request.internalProcessorList = self.processorList;
    request.preferredSize         = self.size;
}

- (void)layoutAndLoad
{
    [self layoutImageView];
    if (self.request.state == LKImageRequestStateFinish
        &&!CGSizeEqualToSize(self.oldSize, self.size)
        &&(!self.presentationImage||self.presentationImage.lk_isScaled))
    {
        [self.request reset];
    }

    if (self.request && self.request.state == LKImageRequestStateInit)
    {
        self.oldSize = self.size;

        __weak LKImageView *wself = self;

        
        

        if (!self.request.synchronized)
        {
            if (self.loadingImageRequest)
            {
                [self dealWithRequest:self.loadingImageRequest];
                [self.imageManager sendRequest:self.loadingImageRequest
                                    completion:^(LKImageRequest *request, UIImage *image, BOOL isFromSyncCache) {
                                        [wself handleRequestFinish:request image:image isFromSyncCache:isFromSyncCache];
                                    }];
            }
        }
        
        [self dealWithRequest:self.request];
        [self.imageManager sendRequest:self.request
                            completion:^(LKImageRequest *request, UIImage *image, BOOL isFromSyncCache) {
                                [wself handleRequestFinish:request image:image isFromSyncCache:isFromSyncCache];
                            }];
    }
}

- (void)handleRequestFinish:(LKImageRequest *)request image:(UIImage *)image isFromSyncCache:(BOOL)isFromSyncCache
{
    [LKImageUtil async:dispatch_get_main_queue()
                 block:^{
                     if (request == self.request)
                     {
                         LKImageLogVerbose(@"requst finish");
                     }
                     else if (request == self.failureImageRequest)
                     {
                         LKImageLogVerbose(@"failureImageRequest finish");
                         if (self.request.state != LKImageRequestStateFinish || !self.request.error)
                         {
                             return;
                         }
                     }
                     else if (request == self.loadingImageRequest)
                     {
                         LKImageLogVerbose(@"loadingImageRequest finish");
                         if (self.request.state == LKImageRequestStateFinish)
                         {
                             return;
                         }
                     }
                     else
                     {
                         [self layoutAndLoad];
                         return;
                     }

                     if (!CGSizeEqualToSize(self.oldSize, self.size)&&image.lk_isScaled)
                     {
                         [self layoutAndLoad];
                         return;
                     }

                     if (request.error)
                     {
                         if (request.error.code == LKImageErrorCodeCancel)
                         {
                             [self layoutAndLoad];
                         }
                         else
                         {
                             LKImageLogError([NSString stringWithFormat:@"%@ error:%@", request, request.error.description]);
                             if (![request isEqual:self.failureImageRequest])
                             {
                                 [self dealWithRequest:self.failureImageRequest];
                                 [self.imageManager sendRequest:self.failureImageRequest
                                                     completion:^(LKImageRequest *request, UIImage *image, BOOL isFromSyncCache) {
                                                         [self handleRequestFinish:request image:image isFromSyncCache:isFromSyncCache];
                                                         
                                                     }];
                             }

                             if ([self.delegate respondsToSelector:@selector(LKImageViewImageDidLoad:request:)])
                             {
                                 [self.delegate LKImageViewImageDidLoad:self request:request];
                             }
                         }
                     }
                     else
                     {
                         if (request.progress < 1.0)
                         {
                             if ([self.delegate respondsToSelector:@selector(LKImageViewImageLoading:request:)])
                             {
                                 [self.delegate LKImageViewImageLoading:self request:request];
                             }
                         }

                         if (image)
                         {
                             if (!self.imageView.image && !request.synchronized &&
                                 ((isFromSyncCache && self.fadeMode & LKImageViewFadeModeAfterCached) ||
                                     (!isFromSyncCache && self.fadeMode & LKImageViewFadeModeAfterLoad)))
                             {
                                 [self playFadeAnimation];
                             }

                             [self internalSetImage:image withRequest:request];
                             if (request.progress >= 1.0)
                             {
                                 if ([self.delegate respondsToSelector:@selector(LKImageViewImageDidLoad:request:)])
                                 {
                                     [self.delegate LKImageViewImageDidLoad:self request:request];
                                 }
                             }
                         }
                     }

                 }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutAndLoad];
}

- (void)internalSetImage:(UIImage *)image withRequest:(LKImageRequest *)request
{
    self.currentRequest  = request;
    _presentationImage   = image;
    self.animationIndex  = 0;
    if (image.images.count > 1)
    {
        self.imageView.image = image.images.firstObject;
        self.imageView.animationImages = image.images;
    }
    else
    {
        self.imageView.image = image;
        self.isAnimating = false;
    }
    if (self.shouldAutoPlay && image.images.count > 1)
    {
        self.isAnimating = YES;
    }
    if (image)
    {
        [self layoutImageView];
    }
}

- (void)setRequest:(LKImageRequest *)request
{
    request.internalProcessorList = self.processorList;
    if (![_request isEqual:request] || _request.error)
    {
        [self.imageManager cancelRequest:_request];
        _request = request;
    }
    if (!_request)
    {
        [self internalSetImage:nil withRequest:nil];
    }

    [self setNeedsLayout];
    if (!self.delayLoadingImage)
    {
        [self layoutIfNeeded];
    }
}

- (void)setLoadingImageRequest:(LKImageRequest *)loadingImageRequest
{
    loadingImageRequest.internalProcessorList = self.processorList;
    if (![_loadingImageRequest isEqual:loadingImageRequest] || _loadingImageRequest.error)
    {
        [self.imageManager cancelRequest:_loadingImageRequest];
        _loadingImageRequest = loadingImageRequest;
    }
    [self setNeedsLayout];
}

- (void)setFailureImageRequest:(LKImageRequest *)failureImageRequest
{
    failureImageRequest.internalProcessorList = self.processorList;
    if (![_failureImageRequest isEqual:failureImageRequest] || _failureImageRequest.error)
    {
        [self.imageManager cancelRequest:_failureImageRequest];
        _failureImageRequest = failureImageRequest;
    }
    [self setNeedsLayout];
}

- (NSArray *)processorList
{
    if (self.predrawEnabled && !CGSizeEqualToSize(self.size, CGSizeZero))
    {
        LKImagePredrawProcessor *p = [[LKImagePredrawProcessor alloc] init];
        p.scaleMode                = self.scaleMode;
        p.anchorPoint              = self.anchorPoint;
        p.size                     = self.size;
        return [self.effect.processorList arrayByAddingObject:p];
    }
    else
    {
        return self.effect.processorList;
    }
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    if (_isAnimating == isAnimating)
    {
        return;
    }
    if (self.presentationImage.images.count <= 1)
    {
        return;
    }

    _isAnimating = isAnimating;
    if (isAnimating)
    {
        [self resetTimer];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setShouldAutoPlay:(BOOL)shouldAutoPlay
{
    _shouldAutoPlay = shouldAutoPlay;
    if (shouldAutoPlay)
    {
        self.isAnimating = YES;
    }
}

- (void)resetTimer
{
    [self.timer invalidate];
    self.timer = nil;
    if (!self.isAnimating)
    {
        return;
    }

    NSTimeInterval frameDuration = self.frameDuration;

    if (frameDuration <= 0)
    {
        LKImageInfo *info = self.presentationImage.lk_imageInfo;
        if ([info isKindOfClass:[LKImageAnimatedImageInfo class]])
        {
            LKImageAnimatedImageInfo *animatedInfo = (LKImageAnimatedImageInfo *) info;
            frameDuration                          = animatedInfo.frameDuration;
        }
    }

    if (frameDuration <= 0)
    {
        frameDuration = 1;
    }

    __weak LKImageView *wself = self;
    self.animationIndex       = 0;
    self.timer                = [NSTimer lk_scheduledTimerWithTimeInterval:frameDuration
                                                    repeats:YES
                                                      block:^(NSTimer *timer) {
                                                          [wself handleAnimation];
                                                      }];
}

- (void)handleAnimation
{
    if (self.presentationImage.images.count == 0)
    {
        return;
    }
    self.animationIndex++;
    if (self.animationMode == LKImageViewAnimationModeNormal)
    {
        if (self.animationRepeatCount == 0 || self.animationIndex < self.animationRepeatCount * self.presentationImage.images.count)
        {
            self.frameIndex = self.animationIndex % self.presentationImage.images.count;
        }
        else
        {
            self.frameIndex = self.presentationImage.images.count - 1;
        }
    }
    else if (self.animationMode == LKImageViewAnimationModeReverse)
    {
        if (self.animationRepeatCount == 0 || self.animationIndex < self.animationRepeatCount * self.presentationImage.images.count)
        {
            self.frameIndex = self.presentationImage.images.count - self.animationIndex % self.presentationImage.images.count - 1;
        }
        else
        {
            self.frameIndex = 0;
        }
    }
    else
    {
        if (self.animationRepeatCount == 0 || self.animationIndex < self.animationRepeatCount * self.presentationImage.images.count)
        {
            if (self.animationIndex / self.presentationImage.images.count % 2 == 0)
            {
                self.frameIndex = self.animationIndex % self.presentationImage.images.count;
            }
            else
            {
                self.frameIndex = self.presentationImage.images.count - self.animationIndex % self.presentationImage.images.count - 1;
            }
        }
        else
        {
            if (self.animationIndex / self.presentationImage.images.count % 2 == 0)
            {
                self.frameIndex = self.presentationImage.images.count - 1;
            }
            else
            {
                self.frameIndex = 0;
            }
        }
    }
    self.imageView.image = self.presentationImage.images[self.frameIndex];
}

- (void)setFrameDuration:(NSTimeInterval)frameDuration
{
    _frameDuration = frameDuration;
    [self resetTimer];
}

- (void)playFadeAnimation
{
    self.imageView.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.imageView.alpha = 1;
                     }];
    //    CATransition *transition       = [CATransition animation];
    //    transition.duration            = 0.3;
    //    transition.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    transition.type                = kCATransitionFade;
    //    transition.removedOnCompletion = YES;
    //    [self.imageView.layer addAnimation:transition forKey:nil];
}

- (void)setScaleMode:(LKImageScaleMode)scaleMode
{
    _scaleMode = scaleMode;
    [self.request reset];
    [self setNeedsLayout];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    switch (contentMode)
    {
        case UIViewContentModeScaleToFill:
            self.scaleMode = LKImageScaleModeScaleToFill;
            break;
        case UIViewContentModeScaleAspectFit:
            self.scaleMode = LKImageScaleModeAspectFit;
            break;
        case UIViewContentModeScaleAspectFill:
            self.scaleMode = LKImageScaleModeAspectFill;
            break;
        case UIViewContentModeCenter:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(0.5, 0.5);
            break;
        case UIViewContentModeTop:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(0.5, 0);
            break;
        case UIViewContentModeBottom:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(0.5, 1);
            break;
        case UIViewContentModeLeft:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(0, 0.5);
            break;
        case UIViewContentModeRight:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(1, 0.5);
            break;
        case UIViewContentModeTopLeft:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(0, 1);
            break;
        case UIViewContentModeTopRight:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(1, 1);
            break;
        case UIViewContentModeBottomLeft:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(0, 0);
            break;
        case UIViewContentModeBottomRight:
            self.scaleMode   = LKImageScaleModeNone;
            self.anchorPoint = CGPointMake(1, 0);
            break;
        default:
            NSLog(@"invalid content mode");
            break;
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    _anchorPoint = anchorPoint;
    [self setNeedsLayout];
}

- (void)sizeToFit
{
    [self.imageView sizeToFit];
    self.bounds = self.imageView.bounds;
}

@end

@implementation LKImageView (Facade)

- (UIImage *)defaultImage
{
    if (self.loadingImage == self.failureImage)
    {
        return self.loadingImage;
    }
    else
    {
        return nil;
    }
}

- (void)setDefaultImage:(UIImage *)defaultImage
{
    self.loadingImage = defaultImage;
    self.failureImage = defaultImage;
}

- (UIImage *)image
{
    if ([self.request isKindOfClass:[LKImageImageRequest class]])
    {
        LKImageImageRequest *request = (LKImageImageRequest *) self.request;
        return request.image;
    }
    return nil;
}

- (UIImage *)loadingImage
{
    if ([self.loadingImageRequest isKindOfClass:[LKImageImageRequest class]])
    {
        LKImageImageRequest *request = (LKImageImageRequest *) self.loadingImageRequest;
        return request.image;
    }
    return nil;
}

- (UIImage *)failureImage
{
    if ([self.failureImageRequest isKindOfClass:[LKImageImageRequest class]])
    {
        LKImageImageRequest *request = (LKImageImageRequest *) self.failureImageRequest;
        return request.image;
    }
    return nil;
}

- (void)setImage:(UIImage *)image
{
    self.loadingImageRequest = nil;
    self.failureImageRequest = nil;
    if (image)
    {
        self.request = [LKImageImageRequest requestWithImage:image];
    }
    else
    {
        self.request = nil;
    }
}

- (void)setLoadingImage:(UIImage *)loadingImage
{
    if (loadingImage)
    {
        self.loadingImageRequest = [LKImageImageRequest requestWithImage:loadingImage];
    }
    else
    {
        self.loadingImageRequest = nil;
    }
}

- (void)setFailureImage:(UIImage *)failureImage
{
    if (failureImage)
    {
        self.failureImageRequest = [LKImageImageRequest requestWithImage:failureImage];
    }
    else
    {
        self.failureImageRequest = nil;
    }
}

- (NSArray<UIImage *> *)images
{
    if ([self.request isKindOfClass:[LKImageImageRequest class]])
    {
        LKImageImageRequest *request = (LKImageImageRequest *) self.request;
        return request.image.images;
    }
    return nil;
}

- (void)setImages:(NSArray<UIImage *> *)images
{
    self.image = [UIImage animatedImageWithImages:images duration:INFINITY];
}

- (NSString *)URL
{
    if ([self.request isKindOfClass:[LKImageURLRequest class]])
    {
        LKImageURLRequest *URLRequest = (LKImageURLRequest *) self.request;
        return URLRequest.URL;
    }
    return nil;
}

- (NSString *)loadingURL
{
    if ([self.loadingImageRequest isKindOfClass:[LKImageURLRequest class]])
    {
        LKImageURLRequest *URLRequest = (LKImageURLRequest *) self.loadingImageRequest;
        return URLRequest.URL;
    }
    return nil;
}

- (NSString *)failureURL
{
    if ([self.failureImageRequest isKindOfClass:[LKImageURLRequest class]])
    {
        LKImageURLRequest *URLRequest = (LKImageURLRequest *) self.failureImageRequest;
        return URLRequest.URL;
    }
    return nil;
}

- (void)setURL:(NSString *)URL
{
    if (!URL)
    {
        self.request = nil;
        return;
    }

    self.request = [LKImageURLRequest requestWithURL:URL key:nil];
}

- (void)setLoadingURL:(NSString *)loadingURL
{
    if (!loadingURL)
    {
        self.loadingImageRequest = nil;
        return;
    }

    self.loadingImageRequest = [LKImageURLRequest requestWithURL:loadingURL key:nil];
}

- (void)setFailureURL:(NSString *)failureURL
{
    if (!failureURL)
    {
        self.failureImageRequest = nil;
        return;
    }

    self.failureImageRequest = [LKImageURLRequest requestWithURL:failureURL key:nil];
}

- (void)setURL:(NSString *)URL andKey:(NSString *)key;
{
    if (!URL)
    {
        self.request = nil;
        return;
    }
    self.request = [LKImageURLRequest requestWithURL:URL key:key];
}

- (void)startAnimating
{
    self.shouldAutoPlay = YES;
}

- (void)stopAnimating
{
    self.shouldAutoPlay = NO;
    self.isAnimating    = NO;
}

@end
