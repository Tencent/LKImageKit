//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
