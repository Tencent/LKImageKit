//
//  LKImageRequest.h
//  LKImageKit
//
//  Created by lingtonke on 15/11/26.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageLoaderManager.h"

@interface LKImageLoader (Private)

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end
