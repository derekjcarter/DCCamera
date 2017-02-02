//
//  DCCameraCollectionViewController.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraCollectionViewController.h"
#import "DCCameraCollectionViewHeader.h"
#import "DCCameraCollectionViewCell.h"
#import "NSIndexSet+DCCamera.h"
#import "UICollectionView+DCCamera.h"

static NSString *const kCellReuseIdentifier     = @"DCPhotoPickerCell";
static NSString *const kHeaderReuseIdentifier   = @"DCPhotoPickerHeader";
static float const kCollectionViewMinSpacing    = 2.0f;
static float const kThumbnailImageSize          = 150.0f;
static int const kNumberOfColumns               = 3;
static float const kMinSizeOfCell               = 100.0f;
static float const kMaxSizeOfCell               = 150.0f;

@interface DCCameraCollectionViewController () <UICollectionViewDelegateFlowLayout, DCCameraCollectionViewHeaderDelegate>

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property CGRect previousPreheatRect;
@property CGFloat sizeOfCell;

@end

@implementation DCCameraCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.imageManager = [[PHCachingImageManager alloc] init];

        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
        self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedAssets = [NSMutableArray new];
    
    if (self.view.frame.size.height > self.view.frame.size.width) {
        self.sizeOfCell = (self.view.frame.size.width-(kCollectionViewMinSpacing*2)-(kCollectionViewMinSpacing*kNumberOfColumns)) / kNumberOfColumns;
    } else {
        self.sizeOfCell = (self.view.frame.size.height-(kCollectionViewMinSpacing*2)-(kCollectionViewMinSpacing*kNumberOfColumns)) / kNumberOfColumns;
    }
    
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.bounces = YES;
    if (self.maxNumberOfPhotos > 1) {
        self.collectionView.allowsMultipleSelection = YES;
    } else {
        self.collectionView.allowsMultipleSelection = NO;
    }
    
    [self.collectionView registerClass:[DCCameraCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    [self.collectionView registerClass:[DCCameraCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];

    DCCameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.assetIdentifier = asset.localIdentifier;
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(kThumbnailImageSize, kThumbnailImageSize)
                                contentMode:PHImageContentModeAspectFit
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if ([cell.assetIdentifier isEqualToString:asset.localIdentifier]) {
                                      cell.image = result;
                                  }
                              }];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
        DCCameraCollectionViewHeader *header = (DCCameraCollectionViewHeader *)reusableview;
        header.tag = 100;
        [header setDelegate:self];
    }
    return reusableview;
}


#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedAssets count] < self.maxNumberOfPhotos || self.maxNumberOfPhotos == 1) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.selectedAssets addObject:asset];
    
    [self updateUsePhotoHeaderButton];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.selectedAssets removeObject:asset];
    
    [self updateUsePhotoHeaderButton];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sizeOfCell < kMaxSizeOfCell && self.sizeOfCell >= kMinSizeOfCell) {
        return CGSizeMake(self.sizeOfCell, self.sizeOfCell);
    }
    if (self.sizeOfCell > kMaxSizeOfCell) {
        return CGSizeMake(kMaxSizeOfCell, kMaxSizeOfCell);
    }
    return CGSizeMake(kMinSizeOfCell, kMinSizeOfCell);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, kCollectionViewMinSpacing, kCollectionViewMinSpacing, kCollectionViewMinSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewMinSpacing;
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}


#pragma mark - DCCameraCollectionViewHeaderDelegate Methods

- (void)selectionDone
{
    [self.delegate didSelectAssets:self.selectedAssets];
}

- (void)selectionCanceled
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PHAsset Caching Methods

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) {
        return;
    }

    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));

    // Check if the collection view is showing an area that is significantly different to the last preheated area.
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect) {
                                NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
                                [removedIndexPaths addObjectsFromArray:indexPaths];
                            }
                              addedHandler:^(CGRect addedRect) {
                                  NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
                                  [addedIndexPaths addObjectsFromArray:indexPaths];
                              }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:CGSizeMake(kThumbnailImageSize, kThumbnailImageSize)
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:CGSizeMake(kThumbnailImageSize, kThumbnailImageSize)
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);

        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }

        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }

        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }

        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) {
        return nil;
    }

    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }

    return assets;
}


#pragma mark - Helper Methods

- (void)updateUsePhotoHeaderButton
{
    DCCameraCollectionViewHeader *header = (DCCameraCollectionViewHeader *) [self.collectionView viewWithTag:100];
    [header setNumberOfPhotosSelected:[self.selectedAssets count]];
}

@end
