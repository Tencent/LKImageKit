//
//  LKImageDefine.m
//  LKImageViewExample
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

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
