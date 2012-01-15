//
//  RSNavigatorControl.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSControl.h>
#import "RSNavigatorControlDataSource.h"
#import "RSNavigatorControlDelegate.h"

@interface RSNavigatorControl : NSControl {
	NSMutableArray *_cells;
	NSArray *_itemIdentifiers;
	NSString *_selectedItemIdentifier;
	__weak id <RSNavigatorControlDataSource> _dataSource;
	__weak id <RSNavigatorControlDelegate> _delegate;
	NSGradient *_fillGradient;
	NSGradient *_alternateFillGradient;
	NSColor *_bottomFillColor;
	NSColor *_alternateBottomFillColor;
	NSGradient *_selectedFillGradient;
	id _windowDidBecomeKeyObservingToken;
	id _windowDidResignKeyObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet id <RSNavigatorControlDataSource> dataSource;
@property (readwrite,assign,nonatomic) IBOutlet id <RSNavigatorControlDelegate> delegate;
@property (readwrite,assign,nonatomic) IBOutlet NSView *contentView;

@property (readwrite,copy,nonatomic) NSString *selectedItemIdentifier;

- (void)reloadData;

@end
