//
//  WCSourceRulerView.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCLineNumberRulerView.h"
#import "WCSourceRulerViewDelegate.h"

@class WCFold,WCSourceTextView;

@interface WCSourceRulerView : WCLineNumberRulerView {
	__weak id <WCSourceRulerViewDelegate> _delegate;
	NSUInteger _clickedLineNumber;
	NSTrackingArea *_codeFoldingTrackingArea;
	WCFold *_foldToHighlight;
	NSRect _rectForFoldHighlight;
}
@property (readwrite,assign,nonatomic) id <WCSourceRulerViewDelegate> delegate;
@property (readonly,nonatomic) WCSourceTextView *sourceTextView;

- (void)drawCodeFoldingRibbonInRect:(NSRect)ribbonRect;
- (void)drawBookmarksInRect:(NSRect)rect;
@end
