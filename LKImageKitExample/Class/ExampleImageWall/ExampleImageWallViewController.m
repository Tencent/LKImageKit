//
//  ExampleImageWallViewController.m
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/21.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import "ExampleImageWallViewController.h"
#import "ExampleUtil.h"

#define PROGRESSBAR_HEIGHT 4

@implementation ExampleImageWallCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.progressBar                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, PROGRESSBAR_HEIGHT)];
        self.progressBar.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.progressBar];
        self.imageView                   = [[LKImageView alloc] initWithFrame:self.bounds];
        self.imageView.delegate          = self;
        self.imageView.delayLoadingImage = NO;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)LKImageViewImageLoading:(LKImageView *)imageView request:(LKImageRequest *)request
{
    self.progressBar.frame = CGRectMake(0, 0, self.frame.size.width * request.progress, PROGRESSBAR_HEIGHT);
}

- (void)LKImageViewImageDidLoad:(LKImageView *)imageView request:(LKImageRequest *)request
{
    self.progressBar.frame = CGRectMake(0, 0, self.frame.size.width, PROGRESSBAR_HEIGHT);
}

- (void)prepareForReuse
{
    self.progressBar.bounds = CGRectMake(0, 0, 0, 4);
}

@end

@interface ExampleImageWallViewController ()



@end

@implementation ExampleImageWallViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing          = 0;
    layout.minimumInteritemSpacing     = 0;
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[ExampleImageWallCell class] forCellWithReuseIdentifier:@"ExampleImageWallCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ImageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleImageWallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExampleImageWallCell" forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size = collectionView.bounds.size.width / 4;
    return CGSizeMake(size, size);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleImageWallCell *imageCell                  = (ExampleImageWallCell *) cell;
    imageCell.imageView.loadingURL                   = [ExampleUtil imageURLFromFileID:indexPath.item + 1 size:64];
    imageCell.imageView.loadingImageRequest.priority = NSOperationQueuePriorityHigh;
    imageCell.imageView.URL                          = [ExampleUtil imageURLFromFileID:indexPath.item + 1 size:256];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleImageWallCell *imageCell = (ExampleImageWallCell *) cell;
    imageCell.imageView.image       = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
