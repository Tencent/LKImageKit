//
//  ExampleCustomPropertyViewController.m
//  LKImageKitExample
//
//  Created by lingtonke on 2017/12/21.
//  Copyright © 2017年 lingtonke. All rights reserved.
//

#import "ExampleCustomPropertyViewController.h"
#import "ExampleUtil.h"
#import <LKImageKit/LKImageKit.h>

@interface ExampleCustomPropertyViewController () <LKImageViewDelegate>

@property (weak, nonatomic) IBOutlet LKImageView *imageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *imageSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scaleModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *progresiveSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *predrawSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *blurSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *graySwitch;
@property (weak, nonatomic) IBOutlet UISlider *anchorPointXSlider;
@property (weak, nonatomic) IBOutlet UISlider *anchorPointYSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fadeModeSwith;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic) UIView *progressView;

@end

@implementation ExampleCustomPropertyViewController

+ (instancetype)instantiate
{
    ExampleCustomPropertyViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.delegate = self;
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
    self.progressView.backgroundColor = [UIColor blackColor];
    [self.imageView addSubview:self.progressView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload:nil];
}

- (void)LKImageViewImageLoading:(LKImageView *)imageView request:(LKImageRequest *)request
{
    self.progressView.hidden = NO;
    self.progressView.frame = CGRectMake(0, 0, self.view.frame.size.width*request.progress, 5);
}

- (void)LKImageViewImageDidLoad:(LKImageView *)imageView request:(LKImageRequest *)request
{
    self.progressView.hidden = YES;
    if (request.error)
    {
        self.infoLabel.text = @"Load image finished with error";
        return;
    }
    NSMutableString *str   = [[NSMutableString alloc] init];
    CGFloat scale          = self.imageView.presentationImage.scale;
    UIImage *image         = self.imageView.presentationImage;
    CGImageAlphaInfo info  = CGImageGetAlphaInfo(image.CGImage);
    NSInteger bytePerPixel = 4;
    if (info == kCGImageAlphaNoneSkipFirst || info == kCGImageAlphaNoneSkipLast)
    {
        bytePerPixel = 3;
    }
    CGSize imageSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    [str appendFormat:@"MemoryUsed:%ldB", (long) (imageSize.width * imageSize.height) * bytePerPixel];
    self.infoLabel.text = str;
}

- (IBAction)reload:(id)sender
{
    self.imageView.image = nil;

    NSArray<NSString *> *URLs = @[
        [ExampleUtil imageURLFromFileID:1
                                   size:256],
        [ExampleUtil imageURLFromFileID:14
                                   size:0],
        [ImageURLPrefix stringByAppendingString:@"gif/1.gif"],
        [ImageURLPrefix stringByAppendingString:@"gif/3.gif"],
        [ImageURLPrefix stringByAppendingString:@"webp/test.webp"],
    ];
    self.imageView.scaleMode          = self.scaleModeSwitch.selectedSegmentIndex;
    self.imageView.predrawEnabled     = self.predrawSwitch.on;
    self.imageView.effect.blurEnabled = self.blurSwitch.on;
    self.imageView.effect.grayEnabled = self.graySwitch.on;
    self.imageView.anchorPoint        = CGPointMake(self.anchorPointXSlider.value, self.anchorPointYSlider.value);
    self.imageView.fadeMode           = self.fadeModeSwith.selectedSegmentIndex;
    LKImageURLRequest *request        = [LKImageURLRequest requestWithURL:URLs[self.imageSwitch.selectedSegmentIndex]];
    request.supportProgressive        = self.progresiveSwitch.on;
    self.imageView.request            = request;
}

- (IBAction)reset:(id)sender
{
    self.imageSwitch.selectedSegmentIndex = 0;
    self.scaleModeSwitch.selectedSegmentIndex = 0;
    self.predrawSwitch.on                     = false;
    self.blurSwitch.on                        = false;
    self.graySwitch.on                        = false;
    self.anchorPointXSlider.value             = 0.5;
    self.anchorPointYSlider.value             = 0.5;
    self.progresiveSwitch.on                  = false;

    [self reload:nil];
}

@end
