//
//  WCSourceRulerView.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCLineNumberRulerView.h"
#import "WCSourceRulerViewDelegate.h"
#import "RSToolTipView.h"

@class WCFold,WCSourceTextView;

@interface WCSourceRulerView : WCLineNumberRulerView <RSToolTipView> {
	__weak id <WCSourceRulerViewDelegate> _delegate;
	NSUInteger _clickedLineNumber;
	NSTrackingArea *_codeFoldingTrackingArea;
	WCFold *_foldToHighlight;
	NSRect _rectForFoldHighlight;
	struct {
		unsigned int drawCurrentLineHighlight:1;
		unsigned int RESERVED:31;
	} _sourceRulerViewFlags;
}
@property (readwrite,assign,nonatomic) id <WCSourceRulerViewDelegate> delegate;
@property (readonly,nonatomic) WCSourceTextView *sourceTextView;

- (void)drawCodeFoldingRibbonInRect:(NSRect)ribbonRect;
- (void)drawBookmarksInRect:(NSRect)rect;
- (void)drawBuildIssuesInRect:(NSRect)buildIssueRect;
@end
