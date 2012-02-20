//
//  RSCollectionView.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSCollectionView.h>
#import "RSCollectionViewDelegate.h"

@interface RSCollectionView : NSCollectionView
@property (readwrite,assign,nonatomic) IBOutlet id <RSCollectionViewDelegate> delegate;
@end
