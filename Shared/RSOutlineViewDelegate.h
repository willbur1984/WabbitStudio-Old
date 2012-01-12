//
//  RSOutlineViewDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSOutlineView.h>

@class RSOutlineView;

@protocol RSOutlineViewDelegate <NSOutlineViewDelegate>
@optional
- (void)handleDeletePressedForOutlineView:(RSOutlineView *)outlineView;
- (void)handleReturnPressedForOutlineView:(RSOutlineView *)outlineView;
- (void)handleSpacePressedForOutlineView:(RSOutlineView *)outlineView;
@end
