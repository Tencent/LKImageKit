//
//  ExampleUtil.h
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/26.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LKImageKit/LKImageKit.h>

#define ImageCount 4000
#define ImageURLPrefix @"http://qzonestyle.gtimg.cn/qzone/app/weishi/client/testimage/"

@interface ExampleUtil : NSObject

+ (NSString *)imageURLFromFile:(NSString *)file size:(NSInteger)size;
+ (NSString *)imageURLFromFileID:(NSInteger)fileID size:(NSInteger)size;

@end
