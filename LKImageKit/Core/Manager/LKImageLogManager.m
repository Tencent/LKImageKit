//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageLogManager.h"
@interface LKImageLogManager ()

@property (nonatomic, strong) NSMutableArray *listenerList;

@end

@implementation LKImageLogManager

+ (instancetype)instance
{
    static LKImageLogManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registerListener:(LKImageLogListener)listener
{
    [self.listenerList addObject:[listener copy]];
}

+ (NSString *)logLevelStr:(LKImageLogLevel)level
{
    switch (level)
    {
        case LKImageLogLevelVerbose:
            return @"LKImageLogVerbose";
        case LKImageLogLevelDebug:
            return @"LKImageLogDebug";
        case LKImageLogLevelInfo:
            return @"LKImageLogInfo";
        case LKImageLogLevelWarning:
            return @"LKImageLogWarning";
        case LKImageLogLevelError:
            return @"LKImageLogError";
    }
}

- (void)log:(LKImageLogLevel)level str:(NSString *)str
{
    if (self.listenerList.count == 0)
    {
        if (level >= LKImageLogLevelDebug)
        {
            NSLog(@"%@:%@", [LKImageLogManager logLevelStr:level], str);
        }
        return;
    }
    for (LKImageLogListener listener in self.listenerList)
    {
        listener(level, str);
    }
}

- (NSMutableArray *)listenerList
{
    if (!_listenerList)
    {
        _listenerList = [NSMutableArray array];
    }
    return _listenerList;
}

@end
