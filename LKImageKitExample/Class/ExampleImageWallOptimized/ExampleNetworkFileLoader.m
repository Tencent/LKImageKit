//
//  ExampleNetworkFileLoader.m
//  LKImageViewExample
//
//  Created by lingtonke on 2018/1/9.
//  Copyright © 2018年 lingtonke. All rights reserved.
//

#import "ExampleNetworkFileLoader.h"
#import "ExampleFastFileCache.h"
#import "ExampleImageURLRequest.h"

@implementation ExampleNetworkFileLoader

- (void)dataWithRequest:(LKImageRequest *)request callback:(LKImageDataCallback)callback
{
    if ([request isKindOfClass:[LKImageURLRequest class]])
    {
        LKImageURLRequest *req = (ExampleImageURLRequest *) request;
        NSLog(@"load:%@",req.URL.lastPathComponent);
    }
    
    [super dataWithRequest:request
                  callback:^(LKImageRequest *request, NSData *data, float progress, NSError *error) {
                      if (data && progress >= 1)
                      {
                          if ([request isKindOfClass:[ExampleImageURLRequest class]])
                          {
                              ExampleImageURLRequest *req = (ExampleImageURLRequest *) request;
                              if (req.dataCacheEnabled)
                              {
                                  [[ExampleFastFileCache instance].cache setObject:data forKey:request.keyForLoader cost:data.length];
                              }
                          }
                      }
                      callback(request, data, progress, error);
                  }];
}

- (LKImageLoaderCancelResult)cancelRequest:(LKImageRequest *)request
{
    if ([request isKindOfClass:[ExampleImageURLRequest class]])
    {
        ExampleImageURLRequest *req = (ExampleImageURLRequest *) request;
        if (req.dataCacheEnabled)
        {
            return LKImageLoaderCancelResultFinishImmediately;
        }
    }
    return [super cancelRequest:request];
}

@end
