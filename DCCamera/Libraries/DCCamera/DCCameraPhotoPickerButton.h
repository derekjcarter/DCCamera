//
//  DCCameraPhotoPickerButton.h
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCCameraPhotoPickerButtonDelegate <NSObject>

- (void)photoPickerViewTapped;

@end

@interface DCCameraPhotoPickerButton : UIView

@property (nonatomic, weak) id<DCCameraPhotoPickerButtonDelegate> delegate;

- (void)setImage:(UIImage *)image;

@end
