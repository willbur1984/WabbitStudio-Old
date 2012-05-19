//
//  WCSourceRulerView.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
