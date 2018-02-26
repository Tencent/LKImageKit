//
//  ExampleUtil.m
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/26.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import "ExampleUtil.h"

@implementation ExampleUtil

+ (NSString *)imageURLFromFile:(NSString *)file size:(NSInteger)size
{
    return [NSString stringWithFormat:@"%@%ld/%@", ImageURLPrefix, (long) size, file];
}

+ (NSString *)imageURLFromFileID:(NSInteger)fileID size:(NSInteger)size
{
    if (size > 0)
    {
        return [NSString stringWithFormat:@"%@%ld/%ld.jpg", ImageURLPrefix, (long) size, (long) fileID];
    }
    else
    {
        return [NSString stringWithFormat:@"%@origin/%ld.jpg", ImageURLPrefix, (long) fileID];
    }
}

@end
