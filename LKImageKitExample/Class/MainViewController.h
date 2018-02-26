//
//  ViewController.h
//  LKImageKitExample
//
//  Created by lingtonke on 15/10/28.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import <LKImageKit/LKImageKit.h>
#import <UIKit/UIKit.h>
#import "Common.h"

@interface MainViewControllerCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet LKImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desclabel;

@end

@interface MainViewController : UICollectionViewController

@end
