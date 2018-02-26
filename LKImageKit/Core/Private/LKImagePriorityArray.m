//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
