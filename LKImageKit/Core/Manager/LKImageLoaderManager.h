//
//  LKImageLoaderManager.h
//  LKImageKit
//
//  Created by lingtonke on 15/8/31.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageDefine.h"
#import "LKImageRequest.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LKImageDecoderManager;

typedef NS_ENUM(NSUInteger, LKImageLoaderCancelResult) {
    LKImageLoaderCancelResultFinishImmediately,
    LKImageLoaderCancelResultWaitForCallback,
};

@protocol LKImageLoaderProtocol <NSObject>
@required

- (BOOL)isValidRequest:(LKImageRequest *_Nonnull)request;

@optional

//choose one of the interfaces
//dataWithRequest: data from loader will be decoded by LKImageDecoderManager and return a UIImage
//imageWithRequest: image from loader will skip decode stage
- (void)dataWithRequest:(LKImageRequest *)request callback:(LKImageDataCallback)callback;
- (void)imageWithRequest:(LKImageRequest *)request callback:(LKImageImageCallback)callback;

@end

@interface LKImageLoader : NSObject <LKImageLoaderProtocol>

@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;
@property (nonatomic, strong) dispatch_queue_t gcd_queue;

- (LKImageLoaderCancelResult)cancelRequest:(LKImageRequest * _Nonnull)request;

- (void)willBeRegistered;
- (void)didBeUnregistered;

@end

@interface LKImageLoaderManager : NSObject

@property (nonatomic, strong) LKImageDecoderManager *decoderManager;

+ (instancetype)defaultManager;

- (instancetype)initWithLoaderList:(NSArray<LKImageLoader *> *_Nullable)loaderList decoderList:(NSArray<LKImageDecoder *> *_Nullable)decoderList;

- (void)registerLoader:(LKImageLoader *)loader;

- (void)unregisterLoader:(LKImageLoader *)loader;

- (void)unregisterAllLoader;

- (id<LKImageLoaderProtocol> _Nullable)loaderForRequest:(LKImageRequest *)request;

- (void)imageWithRequest:(LKImageRequest*)request callback:(LKImageLoaderCallback _Nullable)callback;

- (void)preloadWithRequest:(LKImageRequest*)request;

- (void)cancelRequest:(LKImageRequest *)request;

@end

NS_ASSUME_NONNULL_END
