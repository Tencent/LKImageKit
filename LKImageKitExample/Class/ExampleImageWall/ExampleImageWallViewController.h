//
//  ExampleImageWallViewController.h
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/21.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import <LKImageKit/LKImageKit.h>
#import <UIKit/UIKit.h>
#import "Common.h"

@interface ExampleImageWallCell : UICollectionViewCell <LKImageViewDelegate>

@property (nonatomic) LKImageView *imageView;
@property (nonatomic) UIView *progressBar;

@end

@interface ExampleImageWallViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@end
