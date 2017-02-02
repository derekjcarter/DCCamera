//
//  DCCameraCollectionViewHeader.h
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCCameraCollectionViewHeaderDelegate <NSObject>

- (void)selectionCanceled;
- (void)selectionDone;

@end

@interface DCCameraCollectionViewHeader : UICollectionReusableView

@property (nonatomic, weak) id<DCCameraCollectionViewHeaderDelegate> delegate;
@property (nonatomic, assign) NSUInteger numberOfPhotosSelected;

@end
