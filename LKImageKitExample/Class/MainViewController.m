//
//  ViewController.m
//  LKImageKitExample
//
//  Created by lingtonke on 15/10/28.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "MainViewController.h"
#import "ExampleUtil.h"
#import <UIKit/UIKit.h>

#import "ExampleCustomPropertyViewController.h"
#import "ExampleImageWallOptimizedViewController.h"
#import "ExampleImageWallViewController.h"

@implementation MainViewControllerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end

@interface MainViewController () <UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>

@property (nonatomic) NSArray<NSArray *> *examples;

@end

@implementation MainViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.examples = @[
        @[@"1.jpg", @"自定义属性\nCustomProperty", @"", @"ExampleCustomPropertyViewController"],
        @[@"2.jpg", @"图片墙\nImageWall", @"", @"ExampleImageWallViewController"],
        @[@"3.jpg", @"优化图片墙\nOptimizedImageWall2", @"", @"ExampleImageWallOptimizedViewController"],
        @[@"4.jpg", @"清除缓存\nClearCache", @"", @""],
    ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[LKImageNetworkFileLoader clearCache];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.examples.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MainViewControllerCell *cell        = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *info                       = self.examples[indexPath.item];
    cell.imageView.URL                  = [ExampleUtil imageURLFromFile:info[0] size:1024];
    cell.titleLabel.text                = info[1];
    cell.desclabel.text                 = info[2];
    cell.imageView.request.synchronized = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 3)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"ClearCache" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles:nil];
        [sheet showInView:self.view];
    }
    else
    {
        NSArray *info        = self.examples[indexPath.item];
        Class cls = NSClassFromString(info[3]);
        UIViewController *vc = nil;
        if ([cls conformsToProtocol:@protocol(ExampleVC)])
        {
            vc = [cls performSelector:@selector(instantiate)];
        }
        else
        {
            vc = [[NSClassFromString(info[3]) alloc] init];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.bounds.size.width / 2 - 3;
    return CGSizeMake(width, width);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[LKImageCacheManager defaultManager] clearAll];
    [LKImageNetworkFileLoader clearCache];
}

@end
