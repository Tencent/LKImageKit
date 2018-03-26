//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageMemoryCache.h"
#import "LKImageRequest+Private.h"
#import <list>
#import <map>
#import <string>
#import <vector>
#import <libkern/OSAtomic.h>

using namespace std;

struct ImageNode
{
    string key;
    UIImage *image;
};

struct ImagePointer
{
    list<ImageNode *>::iterator it;
    bool isLRUQueue;
    ImagePointer()
    {
        isLRUQueue = false;
    }
};

@interface LKImageMemoryCache ()
{
    list<ImageNode *> FIFOQueue;
    list<ImageNode *> LRUQueue;
    map<string, ImagePointer *> imageMap;
}

@end

@implementation LKImageMemoryCache

+ (instancetype)defaultCache
{
    NSAssert([NSThread isMainThread], @"LKImageMemoryCache is not running on Main Thread!");
    static LKImageMemoryCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+(OSSpinLock *)lk_lock {
    static OSSpinLock lock = OS_SPINLOCK_INIT;
    return &lock;
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(didReceiveLowMemoryNotification)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
        self.cacheSizeLimit   = 1024 * 1024 * 50;
        self.maxLengthForLRU  = 400;
        self.maxLengthForFIFO = 400;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)clear
{
    OSSpinLockLock([[self class] lk_lock]);
    for (auto it = imageMap.begin(); it != imageMap.end(); it++)
    {
        delete *it->second->it;
        delete it->second;
    }
    FIFOQueue.clear();
    LRUQueue.clear();
    imageMap.clear();
    OSSpinLockUnlock([[self class] lk_lock]);
}

- (void)clearWithURL:(NSString *)URL
{
    vector<string> deleteKeys;
    OSSpinLockLock([[self class] lk_lock]);
    for (auto it = imageMap.begin(); it != imageMap.end(); it++)
    {
        if (it->first.find([URL cStringUsingEncoding:NSUTF8StringEncoding]) != string::npos)
        {
            deleteKeys.push_back(it->first);
        }
    }
    OSSpinLockUnlock([[self class] lk_lock]);

    for (int i = 0; i < deleteKeys.size(); i++)
    {
        [self deleteCache:deleteKeys[i]];
    }
}

- (void)deleteCache:(string)key
{
    OSSpinLockLock([[self class] lk_lock]);
    auto it = imageMap.find(key);
    if (it == imageMap.end())
    {
        OSSpinLockUnlock([[self class] lk_lock]);
        return;
    }
    ImagePointer *ptr = it->second;
    delete *(ptr->it);
    if (ptr->isLRUQueue)
    {
        LRUQueue.erase(ptr->it);
    }
    else
    {
        FIFOQueue.erase(ptr->it);
    }
    delete ptr;
    imageMap.erase(it);
    OSSpinLockUnlock([[self class] lk_lock]);

}

- (void)clearWithKey:(NSString *)key
{
    [self deleteCache:[key cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)keyForURL:(NSString *)URL
{
    return URL;
}

- (void)limitCacheSize
{
    while (self.cacheSize > self.cacheSizeLimit)
    {
        [self clearLastOne];
    }
}

- (void)clearLastOne
{
    if (LRUQueue.size() > 0)
    {
        [self clearLastOneInLRU];
    }
    else
    {
        [self clearLastOneInFIFO];
    }
}

- (void)clearLastOneInLRU
{
    if (LRUQueue.size() > 0)
    {
        ImageNode *node = *LRUQueue.begin();
        LRUQueue.pop_front();
        auto it = imageMap.find(node->key);
        delete it->second;
        delete node;
        imageMap.erase(it);
    }
}

- (void)clearLastOneInFIFO
{
    if (FIFOQueue.size() > 0)
    {
        ImageNode *node = *FIFOQueue.begin();
        FIFOQueue.pop_front();
        auto it = imageMap.find(node->key);
        delete it->second;
        delete node;
        imageMap.erase(it);
    }
}

- (void)cacheImage:(UIImage *)image URL:(NSString *)URL
{
    NSString *key     = [self keyForURL:URL];
    ImagePointer *ptr = NULL;
    OSSpinLockLock([[self class] lk_lock]);
    auto it           = imageMap.find([key cStringUsingEncoding:NSUTF8StringEncoding]);
    if (it == imageMap.end())
    {
        ImageNode *node     = new ImageNode();
        ptr                 = new ImagePointer();
        node->image         = image;
        node->key           = [key cStringUsingEncoding:NSUTF8StringEncoding];
        ptr->it             = FIFOQueue.insert(FIFOQueue.end(), node);
        imageMap[node->key] = ptr;
        if (FIFOQueue.size() > self.maxLengthForFIFO)
        {
            ImageNode *node = *FIFOQueue.begin();
            FIFOQueue.pop_front();
            auto it = imageMap.find(node->key);
            delete it->second;
            delete node;
            imageMap.erase(it);
        }
    }
    else
    {
        ptr               = it->second;
        (*ptr->it)->image = image;
        [self visit:key];
    }
    [self limitCacheSize];
    OSSpinLockUnlock([[self class] lk_lock]);
}

- (int64_t)singleImageSize:(UIImage*)image accurate:(BOOL)accurate
{
    if (accurate)
    {
        CGDataProviderRef data = CGImageGetDataProvider(image.CGImage);
        CFDataRef cfdata       = CGDataProviderCopyData(data);
        int64_t length = CFDataGetLength(cfdata);
        CFRelease(cfdata);
        return length;
    }
    else
    {
        return image.size.width * image.size.height * image.scale * image.scale * 4;
    }
}

- (int64_t)imageSize:(UIImage*)image accurate:(BOOL)accurate
{
    if (image.images.count==0)
    {
        return [self singleImageSize:image accurate:accurate];
    }
    else
    {
        int64_t length = 0;
        for (UIImage *subimage in image.images)
        {
            length += [self singleImageSize:subimage accurate:accurate];
        }
        return length;
    }
}

- (int64_t)cacheSize
{
    return [self cacheSize:NO];
}

- (int64_t)cacheSize:(BOOL)accurate
{
    __block int64_t length = 0;
    for (auto it = imageMap.begin(); it != imageMap.end(); it++)
    {
        UIImage *image = (*it->second->it)->image;
        length += [self imageSize:image accurate:accurate];
    }
    return length;
}
- (void)visit:(NSString *)key
{
    auto it = imageMap.find([key cStringUsingEncoding:NSUTF8StringEncoding]);
    if (it == imageMap.end())
    {
        return;
    }
    ImagePointer *ptr = it->second;
    ImageNode *node   = *ptr->it;
    if (ptr->isLRUQueue)
    {
        LRUQueue.erase(ptr->it);
        ptr->it = LRUQueue.insert(LRUQueue.end(), node);
    }
    else
    {
        ptr->isLRUQueue = true;
        FIFOQueue.erase(ptr->it);
        ptr->it = LRUQueue.insert(LRUQueue.end(), node);
    }

    if (LRUQueue.size() > self.maxLengthForLRU)
    {
        [self clearLastOneInLRU];
    }
}

- (UIImage *)imageWithURL:(NSString *)URL
{
    if (!URL)
    {
        return nil;
    }
    NSString *key = [self keyForURL:URL];
    OSSpinLockLock([[self class] lk_lock]);
    [self visit:key];
    auto it = imageMap.find([key cStringUsingEncoding:NSUTF8StringEncoding]);
    if (it == imageMap.end())
    {
        OSSpinLockUnlock([[self class] lk_lock]);
        return nil;
    }
    UIImage *image = (*it->second->it)->image;
    OSSpinLockUnlock([[self class] lk_lock]);
    return image;
}

- (BOOL)hasCacheWithURL:(NSString *)URL
{
    NSString *key = [self keyForURL:URL];
    OSSpinLockLock([[self class] lk_lock]);
    [self visit:key];
    auto it = imageMap.find([key cStringUsingEncoding:NSUTF8StringEncoding]);
    BOOL res = it != imageMap.end();
    OSSpinLockUnlock([[self class] lk_lock]);
    return res;
}

- (void)didReceiveLowMemoryNotification
{
    [self clear];
}

- (UIImage *)imageForRequest:(LKImageRequest *)request continueLoad:(BOOL *)continueLoad
{
    UIImage *image = [self imageWithURL:request.identifier];
    return image;
}

- (void)cacheImage:(UIImage *)image forRequest:(LKImageRequest *)request
{
    [self cacheImage:image URL:request.identifier];
}

@end
