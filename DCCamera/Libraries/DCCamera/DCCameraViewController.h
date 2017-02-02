//
//  DCCameraViewController.h
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCameraView.h"

@protocol DCCameraViewControllerDelegate <NSObject>

- (void)dcCameraDidCancel;
- (void)dcCameraDidTakePhoto:(UIImage *)image;
- (void)dcCameraDidSelectImageAssets:(NSArray *)assets;

@end

@interface DCCameraViewController : UIViewController

@property (nonatomic, weak) id<DCCameraViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger focusSquareSize;
@property (nonatomic, assign) NSUInteger maximumNumberOfPhotoSelection;

@end
