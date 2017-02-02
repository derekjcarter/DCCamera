//
//  DCCameraViewController.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIView+AutoLayout.h"
#import "DCCameraViewController.h"
#import "DCCameraPhotoPickerButton.h"
#import "DCCameraShutterButton.h"
#import "DCCameraCollectionViewController.h"
#import "DCCameraCollectionViewLayout.h"

@interface DCCameraViewController () <DCCameraDelegate, DCCameraShutterButtonDelegate, DCCameraPhotoPickerButtonDelegate, DCCameraCollectionViewControllerDelegate>

@property (nonatomic, strong) DCCameraView *cameraView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) DCCameraPhotoPickerButton *photoPickerButton;

@end

@implementation DCCameraViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maximumNumberOfPhotoSelection = 1;
        self.focusSquareSize = 100.0f;
        
        [self installCameraView];
        [self installToolBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.cameraView focus];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.toolBar autoSetDimension:ALDimensionHeight toSize:90];
}

- (void)installCameraView
{
    // Check permissions
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusRestricted: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestAppPermissionsWithAlert];
            });
            break;
        }
        case AVAuthorizationStatusDenied: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestAppPermissionsWithAlert];
            });
            break;
        }
        case AVAuthorizationStatusNotDetermined: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestAppPermissionsWithAlert];
            });
            break;
        }
        default:
            break;
    }
    
    // Show camera only in portrait mode
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        self.cameraView = [[DCCameraView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    } else {
        self.cameraView = [[DCCameraView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    [self.cameraView setDelegate:self];
    [self.cameraView setFocusSquareSize:self.focusSquareSize];

    [self.view addSubview:self.cameraView];
}

- (void)installToolBar
{
    self.toolBar = [UIToolbar newAutoLayoutView];
    [self.toolBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolBar setClipsToBounds:YES];
    [self.view addSubview:self.toolBar];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.photoPickerButton = [[DCCameraPhotoPickerButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    UIBarButtonItem *photoPickerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.photoPickerButton];
    self.photoPickerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.photoPickerButton setDelegate:self];
    
    DCCameraShutterButton *takePhotoButton = [[DCCameraShutterButton alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    UIBarButtonItem *takePhotoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:takePhotoButton];
    takePhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [takePhotoButton setDelegate:self];
    
    UIImage *cancelIcon = [UIImage imageNamed:@"cancel"];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.bounds = CGRectMake(0, 0, 36, 36);
    [cancelButton setImage:cancelIcon forState:UIControlStateNormal];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchDown];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized ) {
        self.toolBar.items = @[ photoPickerBarButtonItem, flexibleSpace, takePhotoBarButtonItem, flexibleSpace, cancelBarButtonItem ];
        [self setLastPhotoForPhotoPickerView];
    }
    else {
        self.toolBar.items = @[ flexibleSpace, takePhotoBarButtonItem, flexibleSpace, cancelBarButtonItem ];
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.toolBar.items = @[ photoPickerBarButtonItem, flexibleSpace, takePhotoBarButtonItem, flexibleSpace, cancelBarButtonItem ];
                        [self setLastPhotoForPhotoPickerView];
                        [self viewDidLayoutSubviews];
                    });
                    break;
                }
                case PHAuthorizationStatusRestricted: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self requestAppPermissionsWithAlert];
                    });
                    break;
                }
                case PHAuthorizationStatusDenied: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self requestAppPermissionsWithAlert];
                    });
                    break;
                }
                default:
                    break;
            }
        }];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    /* Uncomment this if you wish the toolbar to rotate but not the camera view.
    CGAffineTransform targetRotation = [coordinator targetTransform];
    CGAffineTransform inverseRotation = CGAffineTransformInvert(targetRotation);
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.cameraView.transform = CGAffineTransformConcat(self.cameraView.transform, inverseRotation);
        self.cameraView.frame = self.view.bounds;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {}];
    */
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}


#pragma mark - Action Methods

- (void)openPhotoPicker:(id)sender
{
    DCCameraCollectionViewLayout *layout = [[DCCameraCollectionViewLayout alloc] init];
    DCCameraCollectionViewController *photoPickerCollectionViewController = [[DCCameraCollectionViewController alloc] initWithCollectionViewLayout:layout];
    photoPickerCollectionViewController.delegate = self;
    photoPickerCollectionViewController.maxNumberOfPhotos = self.maximumNumberOfPhotoSelection;
    
    [self presentViewController:photoPickerCollectionViewController animated:YES completion:nil];
}

- (void)takePhoto:(id)sender
{
    [self.cameraView takePhoto];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
    [self.delegate dcCameraDidCancel];
}


#pragma mark - DCCameraPhotoPickerButtonDelegate Methods

- (void)photoPickerViewTapped
{
    [self openPhotoPicker:nil];
}


#pragma mark - DCCameraShutterButtonDelegate Methods

- (void)shutterButtonTapped
{
    [self takePhoto:nil];
}


#pragma mark - DCCameraDelegate Methods

- (void)didTakePhoto:(UIImage *)photo
{
    [self.delegate dcCameraDidTakePhoto:photo];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - DCCameraCollectionViewControllerDelegate Methods

- (void)didSelectAssets:(NSArray *)assets;
{
    [self.delegate dcCameraDidSelectImageAssets:assets];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}


#pragma mark - Helper Methods

- (void)setLastPhotoForPhotoPickerView
{
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES] ];
    
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    PHAsset *asset = allPhotos[allPhotos.count - 1];
    [imageManager requestImageForAsset:asset
                            targetSize:CGSizeMake(50, 50)
                           contentMode:PHImageContentModeAspectFill
                               options:nil
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                             [self.photoPickerButton setImage:result];
                         }];
}

- (void)setMaximumNumberOfPhotoSelection:(NSUInteger)maximumNumberOfPhotoSelection
{
    if (maximumNumberOfPhotoSelection > 0) {
        _maximumNumberOfPhotoSelection = maximumNumberOfPhotoSelection;
    }
}

- (void)setFocusSquareSize:(NSUInteger)focusSquareSize
{
    if (focusSquareSize > 0) {
        _focusSquareSize = focusSquareSize;
        if (self.cameraView) {
            [self.cameraView setFocusSquareSize:self.focusSquareSize];
        }
    }
}

- (void)requestAppPermissionsWithAlert
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Camera and photo permissions are needed."
                                                                              message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:settingsAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
