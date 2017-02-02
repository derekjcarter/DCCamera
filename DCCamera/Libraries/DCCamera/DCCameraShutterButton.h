//
//  DCCameraShutterButton.h
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCCameraShutterButtonDelegate <NSObject>

- (void)shutterButtonTapped;

@end

@interface DCCameraShutterButton : UIView

@property (nonatomic, weak) id<DCCameraShutterButtonDelegate> delegate;

@end