//
//  DCCameraShutterButton.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraShutterButton.h"

static float const kOuterStroke = 5.0f;
static float const kOuterInnerPadding = 0.0f;

@implementation DCCameraShutterButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect outer = CGRectInset(self.bounds, kOuterStroke, kOuterStroke);
        UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:outer cornerRadius:self.bounds.size.width/2];
        CAShapeLayer *outerLayer = [CAShapeLayer layer];
        outerLayer.path = outerPath.CGPath;
        outerLayer.lineWidth = kOuterStroke;
        outerLayer.strokeColor = [UIColor whiteColor].CGColor;
        outerLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:outerLayer];
        
        CGRect inner = CGRectInset(self.bounds, kOuterStroke+kOuterInnerPadding, kOuterStroke+kOuterInnerPadding);
        UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:inner cornerRadius:self.bounds.size.width/2];
        CAShapeLayer *innerLayer = [CAShapeLayer layer];
        innerLayer.path = innerPath.CGPath;
        innerLayer.fillColor = [UIColor colorWithWhite:1.0f alpha:0.4f].CGColor;
        [self.layer addSublayer:innerLayer];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.bounds;
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}


#pragma mark - UIAction Methods

- (void)action:(id)sender
{
    [self.delegate shutterButtonTapped];
}

@end
