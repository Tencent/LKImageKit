//
//  LKImageRequest.h
//  LKImageKit
//
//  Created by lingtonke on 15/11/26.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageDefine.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageLoader;
@class LKImageProcessor;
typedef NS_ENUM(NSUInteger, LKImageRequestState) {
    LKImageRequestStateInit,
    LKImageRequestStateLoading,
    LKImageRequestStateFinish,
};

@interface LKImageRequest : NSObject

//Identify of request. Indicate requests is equal or not. Always use in memory cache
@property (nonatomic, strong) NSString *identifier;
//Key for loading file. Indicate requests's data is from whitch source. Always use in disk cache
@property (nonatomic, strong) NSString *keyForLoader;

//Support progressive or not.
//If true, data/image from loader will always be decoded and display.
//If false, data/image from loader will be decoded and display only if progress is 1.
@property (nonatomic, assign) BOOL supportProgressive;

@property (nonatomic, assign, readonly) LKImageRequestState state;

//Default is 0
@property (nonatomic, assign) NSOperationQueuePriority priority;

//PreferSize default is equal to LKImageView's size if using LKImageView.
@property (nonatomic, assign) CGSize preferredSize;

//Indicate the image should save in cache or not
@property (nonatomic, assign) BOOL cacheEnabled;

//Processor will progress the image before display
@property (nonatomic, strong) NSArray<LKImageProcessor *> *customProcessorList;

//Indicate the request is synchronized or asynchronized.
//If true, all operation for request will be synchronized.
//If false, cache is synchronized but LKImageManager/LKImageProcessorManager/LKImageLoaderManager has it's own queue.
@property (nonatomic, assign) BOOL synchronized;

@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) BOOL hasCache;

@end

@interface LKImageURLRequest : LKImageRequest

@property (nonatomic, strong) NSString * URL;

+ (nonnull instancetype)requestWithURL:(NSString *)URL;
+ (nonnull instancetype)requestWithURL:(NSString *)URL key:(NSString * _Nullable)key;
+ (nonnull instancetype)requestWithURL:(NSString *)URL key:(NSString * _Nullable)key supportProgressive:(BOOL)supportProgressive;

@end

@interface LKImageImageRequest : LKImageRequest

@property (nonatomic, strong) UIImage * _Nullable image;

+ (nonnull instancetype)requestWithImage:(UIImage *)image;
+ (nonnull instancetype)requestWithImage:(UIImage *)image key:(NSString * _Nullable)key;

@end

NS_ASSUME_NONNULL_END
