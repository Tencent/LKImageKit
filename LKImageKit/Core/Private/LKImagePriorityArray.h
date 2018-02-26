//
//  LKImagePriorityArray.h
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import <Foundation/Foundation.h>

//Ascending Order Array
@interface LKImagePriorityArray <ObjectType> : NSObject

@property (nonatomic,readonly) NSUInteger count;
@property (nullable, nonatomic, readonly) ObjectType firstObject;
@property (nullable, nonatomic, readonly) ObjectType lastObject;

- (void)insertObject:(nonnull ObjectType)anObject priority:(NSInteger)priority isFIFO:(BOOL)isFIFO;

- (nullable ObjectType)objectAtIndex:(NSUInteger)idx;

- (NSInteger)priorityAtIndex:(NSUInteger)idx;

- (NSUInteger)indexOfObject:(nullable ObjectType)object;

- (void)removeObject:(nullable ObjectType)object;

- (void)removeObjectAtIndex:(NSUInteger)idx;

- (void)removeLastObject;

- (void)removeFirstObject;

@end
