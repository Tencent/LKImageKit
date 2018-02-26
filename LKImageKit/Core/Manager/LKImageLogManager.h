//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
