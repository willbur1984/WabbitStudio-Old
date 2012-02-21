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

@class WCFold,WCSourceTextView,WCFileBreakpoint,WCBuildIssue,WCEditBreakpointViewController;

@interface WCSourceRulerView : WCLineNumberRulerView <RSToolTipView> {
	__weak id <WCSourceRulerViewDelegate> _delegate;
	NSUInteger _clickedLineNumber;
	NSTrackingArea *_codeFoldingTrackingArea;
	WCFold *_foldToHighlight;
	WCFileBreakpoint *_clickedFileBreakpoint;
	WCBuildIssue *_clickedBuildIssue;
	WCEditBreakpointViewController *_editBreakpointViewController;
	NSIndexSet *_lineStartIndexesWithBuildIssues;
	struct {
		unsigned int clickedFileBreakpointHasMoved:1;
		unsigned int RESERVED:31;
	} _sourceRulerViewFlags;
}
@property (readwrite,assign,nonatomic) id <WCSourceRulerViewDelegate> delegate;
@property (readonly,nonatomic) WCSourceTextView *sourceTextView;

- (void)drawCodeFoldingRibbonInRect:(NSRect)ribbonRect;
- (void)drawBuildIssuesInRect:(NSRect)buildIssueRect;
- (void)drawFileBreakpointsInRect:(NSRect)breakpointRect;
- (void)drawBookmarksInRect:(NSRect)bookmarkRect;
@end
