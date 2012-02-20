//
//  RSCollectionViewDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSCollectionView.h>

@class RSCollectionView;

@protocol RSCollectionViewDelegate <NSCollectionViewDelegate>
@optional
- (void)handleReturnPressedForCollectionView:(RSCollectionView *)collectionView;
- (void)collectionView:(RSCollectionView *)collectionView handleDoubleClickForItemsAtIndexes:(NSIndexSet *)indexes;
@end
