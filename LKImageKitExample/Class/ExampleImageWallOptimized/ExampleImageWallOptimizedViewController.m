//
//  ExampleImageWallOptimizedViewController.m
//  LKImageViewExample
//
//  Created by lingtonke on 2018/1/9.
//  Copyright © 2018年 lingtonke. All rights reserved.
//

#import "ExampleImageWallOptimizedViewController.h"
#import "ExampleFastFileCache.h"
#import "ExampleImageURLRequest.h"
#import "ExampleNetworkFileLoader.h"
#import "ExampleUtil.h"

@implementation ExampleImageWallOptimizedCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.imageView.imageManager = [LKImageManager imageWallManager];
    }
    return self;
}

@end

@interface ExampleImageWallOptimizedViewController ()

@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) NSMutableArray<ExampleImageURLRequest*> *preloadRequests;

@end

@implementation ExampleImageWallOptimizedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[ExampleImageWallOptimizedCell class] forCellWithReuseIdentifier:@"ExampleImageWallCell"];
    self.mapTable = [[NSMapTable alloc] init];
    self.preloadRequests = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (int i = 0; i < ImageCount; i++)
    {
        ExampleImageURLRequest *request = [ExampleImageURLRequest requestWithURL:[ExampleUtil imageURLFromFileID:i + 1 size:64]];
        request.dataCacheEnabled        = YES;
        request.priority                = NSOperationQueuePriorityVeryLow;
        [[LKImageManager imageWallManager].loaderManager preloadWithRequest:request];
        [self.preloadRequests addObject:request];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    for (ExampleImageURLRequest *request in self.preloadRequests)
    {
        [[LKImageManager imageWallManager].loaderManager cancelRequest:request];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleImageWallCell *imageCell         = (ExampleImageWallCell *) cell;
    ExampleImageURLRequest *loadingRequest  = [ExampleImageURLRequest requestWithURL:[ExampleUtil imageURLFromFileID:indexPath.item + 1 size:64]];
    loadingRequest.priority                 = NSOperationQueuePriorityVeryHigh;
    loadingRequest.dataCacheEnabled         = YES;
    imageCell.imageView.loadingImageRequest = loadingRequest;
    imageCell.imageView.URL                 = [ExampleUtil imageURLFromFileID:indexPath.item + 1 size:256];
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSString *URL           = [ExampleUtil imageURLFromFileID:indexPath.item + 1 size:64];
        LKImageRequest *request = [LKImageURLRequest requestWithURL:URL];
        request.priority = NSOperationQueuePriorityHigh;
        [self.mapTable setObject:request forKey:indexPath];
        [[LKImageManager imageWallManager].loaderManager preloadWithRequest:request];
    }
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths)
    {
        LKImageRequest *request = [self.mapTable objectForKey:indexPath];
        if (request)
        {
            [[LKImageManager imageWallManager].loaderManager cancelRequest:request];
        }
    }
}

@end

@implementation LKImageManager (Example)

+ (instancetype)imageWallManager
{
    static LKImageManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LKImageConfiguration *config = [LKImageConfiguration defaultConfiguration];
        config.cacheList             = [config.cacheList arrayByAddingObject:[ExampleFastFileCache instance]];
        config.loaderList            = [@[[[ExampleNetworkFileLoader alloc] init]] arrayByAddingObjectsFromArray:config.loaderList];
        instance                     = [[LKImageManager alloc] initWithConfiguration:config];
    });
    return instance;
}

@end
