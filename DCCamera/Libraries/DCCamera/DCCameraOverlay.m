//
//  DCCameraOverlay.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraOverlay.h"
#import "DCCameraCheckmark.h"

static float const kCheckmarkDiameter = 30.0f;
static float const kBottomAndRightSidePadding = 4.0f;
static float const kOverlayBorderWidth = 2.0f;

@implementation DCCameraOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        self.layer.borderColor = [[UIColor colorWithRed:20/255.0 green:111/255.0 blue:223/255.0 alpha:1] CGColor];
        self.layer.borderWidth = kOverlayBorderWidth;

        DCCameraCheckmark *checkmark = [[DCCameraCheckmark alloc] initWithFrame:CGRectMake(self.bounds.size.width - (kBottomAndRightSidePadding + kCheckmarkDiameter), self.bounds.size.height - (kBottomAndRightSidePadding + kCheckmarkDiameter), kCheckmarkDiameter, kCheckmarkDiameter)];
        checkmark.autoresizingMask = UIViewAutoresizingNone;
        checkmark.layer.shadowColor = [[UIColor blackColor] CGColor];
        checkmark.layer.shadowOffset = CGSizeMake(0, 0);
        checkmark.layer.shadowOpacity = 0.5;
        checkmark.layer.shadowRadius = 2.0;
        [self addSubview:checkmark];
    }
    return self;
}

@end
