//
//  LKImageDefine.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LKImageLogLevel) {
    LKImageLogLevelVerbose,
    LKImageLogLevelDebug,
    LKImageLogLevelInfo,
    LKImageLogLevelWarning,
    LKImageLogLevelError,
};

typedef void (^LKImageLogListener)(LKImageLogLevel level,NSString * _Nullable str);

@interface LKImageLogManager : NSObject

+ (instancetype)instance;

- (void)registerListener:(LKImageLogListener)listener;

- (void)log:(LKImageLogLevel)level str:(NSString *)str;

@end

inline static void LKImageLogVerbose(NSString * str)
{
    [LKImageLogManager.instance log:LKImageLogLevelVerbose str:str];
}

inline static void LKImageLogDebug(NSString * str)
{
    [LKImageLogManager.instance log:LKImageLogLevelDebug str:str];
}

inline static void LKImageLogInfo(NSString * str)
{
    [LKImageLogManager.instance log:LKImageLogLevelInfo str:str];
}

inline static void LKImageLogWarning(NSString * str)
{
    [LKImageLogManager.instance log:LKImageLogLevelWarning str:str];
}

inline static void LKImageLogError(NSString * str)
{
    [LKImageLogManager.instance log:LKImageLogLevelError str:str];
}

NS_ASSUME_NONNULL_END
