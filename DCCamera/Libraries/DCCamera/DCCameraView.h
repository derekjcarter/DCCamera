//
//  DCCameraView.h
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCCameraDelegate <NSObject>

- (void)didTakePhoto:(UIImage *)image;

@end

@interface DCCameraView : UIView

@property (nonatomic, weak) id<DCCameraDelegate> delegate;

- (void)focus;
- (void)takePhoto;
- (void)setFocusSquareSize:(CGFloat)size;

@end
