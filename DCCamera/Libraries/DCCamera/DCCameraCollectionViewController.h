//
//  DCCameraCollectionViewController.h
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol DCCameraCollectionViewControllerDelegate <NSObject>

- (void)didSelectAssets:(NSArray *)assets;

@end

@interface DCCameraCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<DCCameraCollectionViewControllerDelegate> delegate;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, assign) NSUInteger maxNumberOfPhotos;

@end
