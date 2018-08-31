//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageInfo.h"
#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageManager;
typedef NS_ENUM(NSUInteger, LKImageViewFadeMode) {
    LKImageViewFadeModeNone        = 0,
    LKImageViewFadeModeAfterCached = 1 << 0,
    LKImageViewFadeModeAfterLoad   = 1 << 1,
    LKImageViewFadeModeAlways      = LKImageViewFadeModeAfterCached | LKImageViewFadeModeAfterLoad,
};

typedef NS_ENUM(NSUInteger, LKImageViewAnimationMode) {
    LKImageViewAnimationModeNormal,
    LKImageViewAnimationModeReverse,
    LKImageViewAnimationModePingPong,
};

@class LKImageView;
@class LKImageProcessor;
@class LKImageViewEffect;
@protocol LKImageViewDelegate;

//图片视图类
@interface LKImageView : UIView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, weak) id<LKImageViewDelegate> delegate;

@property (nonatomic, assign) LKImageScaleMode scaleMode;
@property (nonatomic, assign) CGPoint anchorPoint;

@property (nonatomic, assign) BOOL delayLoadingImage;

//default is true: Scale image by size of imageview and cache it.
//Make CPU usage lower and reload after view size changed.(Decoded by CGContextDrawImage)
//false: Use orginal image directly.Scale image by move and scale internal image view.(Decoded by ImageIO)
@property (nonatomic, assign) BOOL predrawEnabled;

@property (nonatomic, strong) LKImageRequest * _Nullable loadingImageRequest;  //image request when loading
@property (nonatomic, strong) LKImageRequest * _Nullable failureImageRequest;  //image request when failed
@property (nonatomic, strong, readonly) UIImage * _Nullable presentationImage; //final image to be display.
@property (nonatomic, strong) LKImageRequest * _Nullable request;              //image request send to LKImageManager and get UIImage from it
@property (nonatomic, assign) LKImageViewFadeMode fadeMode;         //fade mode after load from cache or from loader
@property (nonatomic, readonly) LKImageViewEffect *effect;          //gray/blur etc.
@property (nonatomic, assign) NSTimeInterval frameDuration;         //duration between two frames
@property (nonatomic, assign) NSUInteger animationRepeatCount;      //0 is infinity
@property (nonatomic, assign) BOOL isAnimating;                     //indicate animation is playing or not
@property (nonatomic, assign) BOOL shouldAutoPlay;                  //auto play after load mutiple images
@property (nonatomic, assign) NSUInteger frameIndex;                //index of current image in mutiple images
@property (nonatomic, assign) LKImageViewAnimationMode animationMode;
@property (nonatomic, assign) BOOL isAnimationUseTimer;

@property (nonatomic, strong) LKImageManager *imageManager;

@end

@interface LKImageView (Facade)

//default image(loadingImage and failtrueImage)
@property (nonatomic, strong) UIImage * _Nullable defaultImage;
//image
@property (nonatomic, strong) UIImage * _Nullable image;
@property (nonatomic, strong) UIImage * _Nullable loadingImage;
@property (nonatomic, strong) UIImage * _Nullable failureImage;

//animation image
@property (nonatomic, strong) NSArray<UIImage *> * _Nullable images;

@property (nonatomic, strong) NSString * _Nullable URL;
@property (nonatomic, strong) NSString * _Nullable loadingURL;
@property (nonatomic, strong) NSString * _Nullable failureURL;

- (void)setURL:(NSString *)URL andKey:(NSString *)key;

- (void)startAnimating;
- (void)stopAnimating;

@end

@protocol LKImageViewDelegate <NSObject>
@optional

- (void)LKImageViewImageLoading:(LKImageView *)imageView request:(LKImageRequest *)request;
- (void)LKImageViewImageDidLoad:(LKImageView *)imageView request:(LKImageRequest *)request;

@end

@interface LKImageViewEffect : NSObject

@property (nonatomic, assign) BOOL blurEnabled;
@property (nonatomic, assign) CGFloat blurRadius; //default is 0.3
@property (nonatomic, strong) UIColor *blurTintColor;

@property (nonatomic, assign) BOOL grayEnabled; //covert to gray image

@end

NS_ASSUME_NONNULL_END
