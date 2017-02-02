//
//  DCCameraView.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DCCameraView.h"
#import "DCCameraFocusSquare.h"

@interface DCCameraView ()

@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) DCCameraFocusSquare *focusSquare;

@end

@implementation DCCameraView
{
    CGFloat _focusSquareSize;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        
        [self installCamera];
    }
    return self;
}

- (void)installCamera
{
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    NSError *error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    
    if (self.videoInput) {
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        self.session = [[AVCaptureSession alloc] init];
        [self.session setSessionPreset:AVCaptureSessionPresetHigh]; // You can change the quality here
        [self.session addInput:self.videoInput];
        [self.session addOutput:self.stillImageOutput];
        
        self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.captureVideoPreviewLayer.frame = self.bounds;
        self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        /* This is needed when rotation is allowed on the camera view
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIDeviceOrientationPortrait:
                NSLog(@"UIDeviceOrientationPortrait");
                self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                NSLog(@"UIDeviceOrientationPortraitUpsideDown");
                self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIDeviceOrientationLandscapeLeft:
                NSLog(@"UIDeviceOrientationLandscapeLeft");
                self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                NSLog(@"UIDeviceOrientationLandscapeRight");
                self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            default:
                NSLog(@"OTHER");
                if (self.frame.size.height > self.frame.size.width) {
                    self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                } else {
                    // Default to right (home button on the right)
                    self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                }
                break;
        }
        */
        [self.layer addSublayer:self.captureVideoPreviewLayer];
        
        [self.session startRunning];
        [self focusAtPoint:self.center];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}


#pragma mark - Public Methods

- (void)focus
{
    [self focusAtPoint:self.center];
    [self showFocusSquareAtPoint:self.center];
}

- (void)takePhoto
{
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection == nil) {
        return;
    }
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:[self getAVCaptureVideoOrientationFromDeviceOrientation]];
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           if (imageDataSampleBuffer == NULL) {
                                                               return;
                                                           }
                                                           
                                                           NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

                                                           if ([self.delegate respondsToSelector:@selector(didTakePhoto:)]) {
                                                               UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                               [self.delegate didTakePhoto:image];
                                                           }
                                                       }];
}

- (void)setFocusSquareSize:(CGFloat)size
{
    _focusSquareSize = size;
}


#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    
    if ([[touch view] isKindOfClass:[DCCameraView class]]) {
        [self focusAtPoint:touchPoint];
        [self showFocusSquareAtPoint:touchPoint];
    }
}


#pragma mark - Focus Methods

- (void)focusAtPoint:(CGPoint)point;
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            double focus_x = 1.0f - point.x / screenRect.size.width;
            double focus_y = point.y / screenRect.size.height;
            CGPoint focusPoint = CGPointMake(focus_y, focus_x);
            if ([device lockForConfiguration:nil]) {
                [device setFocusPointOfInterest:focusPoint];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposurePointOfInterest:focusPoint];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                [device unlockForConfiguration];
            }
        }
    }
}

- (void)showFocusSquareAtPoint:(CGPoint)point
{
    if (self.focusSquare) {
        [self.focusSquare removeFromSuperview];
    }
    
    self.focusSquare = [[DCCameraFocusSquare alloc] initWithFrame:CGRectMake(point.x-(_focusSquareSize/2), point.y-(_focusSquareSize/2), _focusSquareSize, _focusSquareSize)];
    [self.focusSquare setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.focusSquare];
    [self.focusSquare setNeedsDisplay];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    [self.focusSquare setAlpha:0.0];
    [UIView commitAnimations];
}


#pragma mark - Helper Methods

- (AVCaptureVideoOrientation)getAVCaptureVideoOrientationFromDeviceOrientation
{
    /* This is preferred when view rotation is allowed
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        default:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
    */
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        default:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            //return AVCaptureVideoOrientationPortraitUpsideDown;
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
}

@end
