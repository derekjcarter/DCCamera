//
//  DCCameraCollectionViewLayout.m
//  DCCamera
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCCameraCollectionViewLayout.h"

@implementation DCCameraCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.minimumLineSpacing = 5.0;
//        self.minimumInteritemSpacing = 5.0;
//        self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
        self.headerReferenceSize = CGSizeMake(0, 52);
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Sticky Headers: http://blog.radi.ws/post/32905838158/sticky-headers-for-uicollectionview-using#notes
    // Stretchy Headers: https://nrj.io/stretchy-uicollectionview-headers/
    
    UICollectionView *collectionView = [self collectionView];
    UIEdgeInsets insets = [collectionView contentInset];
    CGPoint offset = [collectionView contentOffset];
    CGFloat minY = -insets.top;
    
    NSMutableArray *attributesArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributesArray) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributesArray) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }

    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];

        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];

        [attributesArray addObject:layoutAttributes];
    }];
    
    UICollectionView *const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;

    for (UICollectionViewLayoutAttributes *layoutAttributes in attributesArray) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];

            NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];

            UICollectionViewLayoutAttributes *firstObjectAttrs;
            UICollectionViewLayoutAttributes *lastObjectAttrs;

            if (numberOfItemsInSection > 0) {
                firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
            } else {
                firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:lastObjectIndexPath];
            }

            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
            CGPoint origin = layoutAttributes.frame.origin;
            origin.y = MIN(
                MAX(
                    contentOffset.y + cv.contentInset.top,
                    (CGRectGetMinY(firstObjectAttrs.frame) - headerHeight)),
                (CGRectGetMaxY(lastObjectAttrs.frame) - headerHeight));

            layoutAttributes.zIndex = 1024;
            layoutAttributes.frame = (CGRect){
                .origin = origin,
                .size = layoutAttributes.frame.size};
            
            if (offset.y < minY) {
                CGFloat deltaY = fabs(offset.y - minY);
                
                CGRect headerRect = [layoutAttributes frame];
                headerRect.size.height = headerHeight;
                headerRect.origin.y = headerRect.origin.y - deltaY;
                [layoutAttributes setFrame:headerRect];
            }
        }
    }

    return attributesArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return YES;
}

@end
