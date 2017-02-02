//
//  DemoViewController.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DemoViewController.h"
#import "DCCameraViewController.h"
#import <Photos/Photos.h>

@interface DemoViewController () <DCCameraViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Actions

- (IBAction)openCameraView:(id)sender
{
    DCCameraViewController *camera = [[DCCameraViewController alloc] init];
    [camera setDelegate:self];
    [camera setFocusSquareSize:75.0];
    [camera setMaximumNumberOfPhotoSelection:3];
    
    [self presentViewController:camera animated:YES completion:NULL];
}

- (IBAction)pageTurn:(UIPageControl *)pageControl
{
    int whichPage = (int)pageControl.currentPage;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * whichPage, 0.0f);
    [UIView commitAnimations];
}


#pragma mark - DCCameraViewControllerDelegate Methods

- (void)dcCameraDidCancel
{
    NSLog(@"DemoViewController | dcCameraViewDidCancel");
}

- (void)dcCameraDidTakePhoto:(UIImage *)image
{
    NSLog(@"DemoViewController | didTakePhoto : %@", image);
    if (image) {
        [self addImagesToScrollView:@[image]];
    }
}

- (void)dcCameraDidSelectImageAssets:(NSArray *)assets
{
    NSLog(@"DemoViewController | didDismissViewWithAssets : %@", assets);
    
    if (assets) {
        PHImageManager *imageManager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        
        __block NSUInteger count = 0;
        __block NSMutableArray *images = [NSMutableArray new];
        for (PHAsset *asset in assets) {
            @autoreleasepool {
                [imageManager requestImageForAsset:asset
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:options
                                     resultHandler:^(UIImage *image, NSDictionary *info) {
                                         if (image) {
                                             [images addObject:image];
                                         }
                                         count++;
                                         
                                         if (count == [assets count]) {
                                             [self addImagesToScrollView:images];
                                         }
                                     }];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page != -1 && page != 3) {
        self.pageControl.currentPage = page;
    }
}


#pragma mark - Helper Methods

- (void)addImagesToScrollView:(NSArray *)images
{
    if (!images || ![images count]) {
        NSLog(@"No images to load");
        return;
    }
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([images count] > 1) {
        self.pageControl.numberOfPages = [images count];
    } else {
        self.pageControl.numberOfPages = 0;
    }
    
    UIImageView *previousImageView;
    for (UIImage *image in images) {
        UIImageView *imageView = [UIImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollView addSubview:imageView];
        [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(==scrollView)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{
                                                                                           @"imageView": imageView,
                                                                                           @"scrollView": self.scrollView
                                                                                           }]];
        
        if (!previousImageView) { // Pin the first to the left
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView(==scrollView)]"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{
                                                                                              @"imageView": imageView,
                                                                                              @"scrollView": self.scrollView
                                                                                              }]];
        } else { // Pin the rest to the previous item
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousImageView][imageView(==scrollView)]"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{
                                                                                              @"previousImageView": previousImageView,
                                                                                              @"imageView": imageView,
                                                                                              @"scrollView": self.scrollView
                                                                                              }]];
        }
        previousImageView = imageView;
    }
    
    // Pin to the bottom and right
    [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{
                                                                                       @"previousImageView": previousImageView
                                                                                       }]];
    [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{
                                                                                       @"previousImageView": previousImageView
                                                                                       }]];
}

@end
