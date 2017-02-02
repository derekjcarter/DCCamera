//
//  DCCameraCollectionViewHeader.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraCollectionViewHeader.h"
#import "UIView+AutoLayout.h"

@interface DCCameraCollectionViewHeader ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation DCCameraCollectionViewHeader
{
    UIButton *_usePhotoButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.toolbar = [UIToolbar newAutoLayoutView];
        self.toolbar.barStyle = UIBarStyleBlackOpaque;
        [self addSubview:self.toolbar];

        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        NSString *cancelString = NSLocalizedStringFromTable(@"Cancel", @"DCCamera", Nil);
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.bounds = CGRectMake(0, 0, 65, 30);
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cancelButton.titleLabel.numberOfLines = 1;
        cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cancelButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [cancelButton setTitle:cancelString forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchDown];

        NSString *useString = NSLocalizedStringFromTable(@"Use Photo", @"DCCamera", Nil);
        _usePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _usePhotoButton.bounds = CGRectMake(0, 0, 100, 30);
        _usePhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _usePhotoButton.titleLabel.numberOfLines = 1;
        _usePhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _usePhotoButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [_usePhotoButton setTitle:useString forState:UIControlStateNormal];
        [_usePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIBarButtonItem *usePhotoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_usePhotoButton];
        [_usePhotoButton addTarget:self action:@selector(usePhoto:) forControlEvents:UIControlEventTouchDown];

        self.toolbar.items = @[ cancelBarButtonItem, flexibleSpace, usePhotoBarButtonItem ];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self.toolbar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.toolbar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.toolbar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.toolbar autoSetDimension:ALDimensionHeight toSize:self.frame.size.height-2];
}


#pragma mark - Public Methods

- (void)setNumberOfPhotosSelected:(NSUInteger)numberOfPhotosSelected
{
    _numberOfPhotosSelected = numberOfPhotosSelected;
    
    NSString *useString;
    if (numberOfPhotosSelected > 1) {
        useString = NSLocalizedStringFromTable(@"Use Photos", @"DCCamera", nil);
    } else {
        useString = NSLocalizedStringFromTable(@"Use Photo", @"DCCamera", nil);
    }
    [_usePhotoButton setTitle:useString forState:UIControlStateNormal];
}


#pragma mark - Action Methods

- (void)cancel:(id)sender
{
    [self.delegate selectionCanceled];
}

- (void)usePhoto:(id)sender
{
    [self.delegate selectionDone];
}

@end
