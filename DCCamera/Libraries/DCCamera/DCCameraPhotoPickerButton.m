//
//  DCCameraPhotoPickerButton.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraPhotoPickerButton.h"

@interface DCCameraPhotoPickerButton ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation DCCameraPhotoPickerButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imageView.layer.borderWidth = 2.0f;
        self.imageView.layer.cornerRadius = frame.size.width / 4.0;
        [self addSubview:self.imageView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isTapped:)];
        [tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


#pragma mark - Gesture Methods

- (void)isTapped:(UIGestureRecognizer *)gesture
{
    [self.delegate photoPickerViewTapped];
}


#pragma mark - Public Methods

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}

@end
