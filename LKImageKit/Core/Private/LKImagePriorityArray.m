//
//  LKImagePriorityArray.m
//  LKImageKit
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImagePriorityArray.h"

@interface LKImagePriorityArrayObject : NSObject

@property (nonatomic, strong) NSObject *object;
@property (nonatomic, assign) NSInteger priority;

+ (LKImagePriorityArrayObject *)objectFrom:(NSObject *)object priority:(NSInteger)priority;

@end

@implementation LKImagePriorityArrayObject

+ (LKImagePriorityArrayObject *)objectFrom:(NSObject *)object priority:(NSInteger)priority
{
    LKImagePriorityArrayObject *obj = [[LKImagePriorityArrayObject alloc] init];
    obj.object                      = object;
    obj.priority                    = priority;
    return obj;
}

@end

@interface LKImagePriorityArray ()

@property (nonatomic, strong) NSMutableArray<LKImagePriorityArrayObject *> *array;

@end

@implementation LKImagePriorityArray

- (instancetype)init
{
    if (self = [super init])
    {
        self.array = [NSMutableArray array];
    }
    return self;
}

- (void)insertObject:(id)anObject priority:(NSInteger)priority isFIFO:(BOOL)isFIFO
{
    LKImagePriorityArrayObject *newObj = [LKImagePriorityArrayObject objectFrom:anObject priority:priority];
    if (isFIFO)
    {
        for (int i = 0; i < self.array.count; i++)
        {
            LKImagePriorityArrayObject *obj = self.array[i];
            if (obj.priority >= priority)
            {
                [self.array insertObject:newObj atIndex:i];
                return;
            }
        }
        [self.array addObject:newObj];
    }
    else
    {
        for (NSInteger i = (NSInteger) self.array.count - 1; i >= 0; i--)
        {
            LKImagePriorityArrayObject *obj = self.array[i];
            if (obj.priority <= priority)
            {
                [self.array insertObject:newObj atIndex:i + 1];
                return;
            }
        }
        [self.array insertObject:newObj atIndex:0];
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [self.array objectAtIndex:idx].object;
}

- (NSInteger)priorityAtIndex:(NSUInteger)idx
{
    return [self.array objectAtIndex:idx].priority;
}

- (NSUInteger)indexOfObject:(id)object
{
    for (int i = 0; i < self.array.count; i++)
    {
        if (self.array[i].object == object)
        {
            return i;
        }
    }
    return NSNotFound;
}

- (void)removeObject:(id)object
{
    [self removeObjectAtIndex:[self indexOfObject:object]];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    if (idx == NSNotFound)
    {
        return;
    }
    [self.array removeObjectAtIndex:idx];
}

- (void)removeLastObject
{
    if (self.array.count > 0)
    {
        [self removeObjectAtIndex:self.array.count - 1];
    }
}

- (void)removeFirstObject
{
    [self removeObjectAtIndex:0];
}

- (NSUInteger)count
{
    return self.array.count;
}

- (id)firstObject
{
    return self.array.firstObject.object;
}

- (id)lastObject
{
    return self.array.lastObject.object;
}

@end
