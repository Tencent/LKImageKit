//
//  ExampleImageWallOptimizedViewController.h
//  LKImageViewExample
//
//  Created by lingtonke on 2018/1/9.
//  Copyright © 2018年 lingtonke. All rights reserved.
//

#import "ExampleImageWallViewController.h"

@interface ExampleImageWallOptimizedCell : ExampleImageWallCell

@end

@interface ExampleImageWallOptimizedViewController : ExampleImageWallViewController<UICollectionViewDataSourcePrefetching>

@end

@interface LKImageManager (Example)

+ (instancetype)imageWallManager;

@end
