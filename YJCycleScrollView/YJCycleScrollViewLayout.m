//
//  YJCycleScrollViewLayout.m
//  YJCycleScrollView
//
//  Created by Jet on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import "YJCycleScrollViewLayout.h"

@implementation YJCycleScrollViewLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat currentOffset;
    CGRect targetRect;
    CGFloat newProposedContentOffset;
    
    CGFloat collectionWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat collectionHeight = CGRectGetHeight(self.collectionView.bounds);
    
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            currentOffset = self.collectionView.contentOffset.x;
            newProposedContentOffset = proposedContentOffset.x + CGRectGetWidth(self.collectionView.bounds) * 0.5;
            targetRect = CGRectMake(newProposedContentOffset, self.collectionView.bounds.origin.y, collectionWidth, collectionHeight);
            break;
        }
            
        case UICollectionViewScrollDirectionVertical: {
            currentOffset = self.collectionView.contentOffset.y;
            newProposedContentOffset = proposedContentOffset.y + CGRectGetHeight(self.collectionView.bounds) * 0.5;
            targetRect = CGRectMake(self.collectionView.bounds.origin.x, newProposedContentOffset, collectionWidth, collectionHeight);
            break;
        }
    }
    
    NSArray *visibleItemAttrs = [self layoutAttributesForElementsInRect:targetRect];
    
    if (visibleItemAttrs.count) {
        UICollectionViewLayoutAttributes *lastItemAttr = visibleItemAttrs.firstObject;
        
        for (UICollectionViewLayoutAttributes *attr in visibleItemAttrs) {
            
            if (attr.representedElementCategory != UICollectionElementCategoryCell) continue;
            CGFloat nextItemOffset, lastItemOffset;
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    nextItemOffset = attr.center.x - newProposedContentOffset;
                    lastItemOffset = lastItemAttr.center.x - newProposedContentOffset;
                    break;
                }
                    
                case UICollectionViewScrollDirectionVertical: {
                    nextItemOffset = attr.center.y - newProposedContentOffset;
                    lastItemOffset = lastItemAttr.center.y - newProposedContentOffset;
                    break;
                }
            }

            if (fabs(nextItemOffset) < fabs(lastItemOffset)) {
                lastItemAttr = attr;
            }
        }
        
        CGFloat maxDistance, finalTargetOffset;
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
                maxDistance = self.itemSize.width + self.minimumLineSpacing;
                finalTargetOffset = lastItemAttr.center.x - collectionWidth * 0.5;
                break;
            }
                
            case UICollectionViewScrollDirectionVertical: {
                maxDistance = self.itemSize.height + self.minimumLineSpacing;
                finalTargetOffset = lastItemAttr.center.y - collectionHeight * 0.5;
                break;
            }
        }
        
        CGFloat distance = finalTargetOffset - currentOffset;

        if (distance > maxDistance) {
            CGFloat adjust = ((NSInteger)distance / (NSInteger)maxDistance) * maxDistance;
            finalTargetOffset -= adjust;
        }
        
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
                return CGPointMake(finalTargetOffset, proposedContentOffset.y);
            }
                
            case UICollectionViewScrollDirectionVertical: {
                return CGPointMake(proposedContentOffset.x, finalTargetOffset);
            }
        }
    }
    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
}

@end
