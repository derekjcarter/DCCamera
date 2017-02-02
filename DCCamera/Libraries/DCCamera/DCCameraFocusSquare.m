//
//  DCCameraFocusSquare.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraFocusSquare.h"

static float const kLineWidth       = 2.0f;
static float const kInnerLineLength = 8.0f;
static int const kAnimationCount    = 4;

@implementation DCCameraFocusSquare

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = kLineWidth;
        
        CGFloat x = frame.size.width / 2.0;
        CGFloat y = frame.size.height / 2.0;
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(0, y)];
        [linePath addLineToPoint:CGPointMake(kInnerLineLength, y)];
        [linePath moveToPoint:CGPointMake(x, 0)];
        [linePath addLineToPoint:CGPointMake(x, kInnerLineLength)];
        [linePath moveToPoint:CGPointMake(frame.size.width, y)];
        [linePath addLineToPoint:CGPointMake(frame.size.width - kInnerLineLength, y)];
        [linePath moveToPoint:CGPointMake(x, frame.size.height)];
        [linePath addLineToPoint:CGPointMake(x, frame.size.height - kInnerLineLength)];
        
        CAShapeLayer *innerLine = [CAShapeLayer layer];
        innerLine.path = linePath.CGPath;
        innerLine.lineWidth = kLineWidth;
        innerLine.fillColor = nil;
        innerLine.opacity = 1.0;
        innerLine.strokeColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:innerLine];
        
        CABasicAnimation *layerAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        layerAnimation.toValue = (id)[UIColor yellowColor].CGColor;
        layerAnimation.repeatCount = kAnimationCount;
        [self.layer addAnimation:layerAnimation forKey:@"layer"];
        
        CABasicAnimation *innerLineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        innerLineAnimation.toValue = (id)[UIColor yellowColor].CGColor;
        innerLineAnimation.repeatCount = kAnimationCount;
        [innerLine addAnimation:innerLineAnimation forKey:@"innerLine"];
    }
    return self;
}

@end
