//
//  DCCameraCollectionViewCell.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraCollectionViewCell.h"
#import "DCCameraOverlay.h"

@interface DCCameraCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DCCameraOverlay *overlay;

@end

@implementation DCCameraCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        
        self.imageView = imageView;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.imageView.image = nil;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self hideOverlay];
        [self showOverlay];
    } else {
        [self hideOverlay];
    }
}


#pragma mark - Overlay Methods

- (void)showOverlay
{
    DCCameraOverlay *overlay = [[DCCameraOverlay alloc] initWithFrame:self.contentView.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:overlay];
    
    self.overlay = overlay;
}

- (void)hideOverlay
{
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}


#pragma mark - Accessors

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end
