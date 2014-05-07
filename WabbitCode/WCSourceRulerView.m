//
//  WCSourceRulerView.m
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

#import "WCSourceRulerView.h"
#import "WCSourceTextStorage.h"
#import "NSTextView+WCExtensions.h"
#import "RSDefines.h"
#import "NSArray+WCExtensions.h"
#import "RSBookmark.h"
#import "NSString+RSExtensions.h"
#import "WCSourceScanner.h"
#import "NSArray+WCExtensions.h"
#import "AIColorAdditions.h"
#import "WCEditorViewController.h"
#import "NSObject+WCExtensions.h"
#import "WCFold.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCFontAndColorThemeManager.h"
#import "WCFontAndColorTheme.h"
#import "WCSourceTypesetter.h"
#import "WCFoldAttachmentCell.h"
#import "WCSourceTextView.h"
#import "WCBuildIssue.h"
#import "WCProjectDocument.h"
#import "WCBuildController.h"
#import "RSToolTipManager.h"
#import "WCFileBreakpoint.h"
#import "WCBreakpointManager.h"
#import "WCAlertsViewController.h"
#import "NSAlert-OAExtensions.h"
#import "WCProjectWindowController.h"
#import "RSNavigatorControl.h"
#import "WCIssueNavigatorViewController.h"
#import "WCEditBreakpointViewController.h"

@interface WCSourceRulerView ()
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@property (readwrite,assign,nonatomic) NSUInteger clickedLineNumber;
@property (readwrite,assign,nonatomic) WCFold *foldToHighlight;
@property (readwrite,assign,nonatomic) WCFileBreakpoint *clickedFileBreakpoint;
@property (readwrite,assign,nonatomic) BOOL didReceiveMouseDown;
@property (readwrite,assign,nonatomic) WCBuildIssue *clickedBuildIssue;
@property (readwrite,assign,nonatomic) BOOL clickedFileBreakpointHasMoved;
@property (readonly,nonatomic) WCEditBreakpointViewController *editBreakpointViewController;
@property (readwrite,copy,nonatomic) NSIndexSet *lineStartIndexesWithBuildIssues;

- (NSUInteger)_lineNumberForPoint:(NSPoint)point;
- (NSRange)_rangeForPoint:(NSPoint)point;
- (void)_drawFoldsForFold:(WCFold *)fold inRect:(NSRect)ribbonRect topLevelFoldColor:(NSColor *)topLevelFoldColor stepAmount:(CGFloat)stepAmount level:(NSUInteger)level;
- (void)_drawFoldHighlightInRect:(NSRect)ribbonRect;
- (void)_updateCodeFoldingTrackingArea;
- (NSRect)_rectForFold:(WCFold *)fold inRect:(NSRect)ribbonRect;
@end

@implementation WCSourceRulerView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_foldToHighlight = nil;
	_clickedBuildIssue = nil;
	_clickedFileBreakpoint = nil;
	[_editBreakpointViewController release];
	[_codeFoldingTrackingArea release];
	[super dealloc];
}

+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Enable Bookmark", @"Enable Bookmark") action:@selector(_toggleBookmark:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Remove All Bookmarks\u2026", @"Remove All Bookmarks with ellipsis") action:@selector(removeAllBookmarks:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Edit Breakpoint", @"Edit Breakpoint") action:@selector(_editBreakpoint:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Enable Breakpoint", @"Enable Breakpoint") action:@selector(_toggleBreakpoint:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete Breakpoint", @"Delete Breakpoint") action:@selector(_deleteBreakpoint:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Hide Issue", @"Hide Issue") action:@selector(_toggleIssue:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Reveal in Breakpoint Navigator", @"Reveal in Breakpoint Navigator") action:@selector(_revealInBreakpointNavigator:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Reveal in Issue Navigator", @"Reveal in Issue Navigator") action:@selector(_revealInIssueNavigator:) keyEquivalent:@""];
	});
	return retval;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSMenu *retval = [super menuForEvent:event];
	
	if (retval) {
		NSPoint point = [self convertPointFromBase:[event locationInWindow]];
		NSUInteger lineNumber = [self _lineNumberForPoint:point];
		NSRange range = [self _rangeForPoint:point];
		WCFileBreakpoint *fileBreakpoint = [[[self delegate] fileBreakpointsForSourceRulerView:self] fileBreakpointForRange:range];
		WCBuildIssue *buildIssue = [[[self delegate] buildIssuesForSourceRulerView:self] buildIssueForRange:range];
		
		[self setClickedLineNumber:lineNumber];
		[self setClickedFileBreakpoint:fileBreakpoint];
		[self setClickedBuildIssue:buildIssue];
	}
	
	return retval;
}

- (id)supplementalTargetForAction:(SEL)action sender:(id)sender {
	if (action == @selector(removeAllBookmarks:))
		return [self sourceTextView];
	return [super supplementalTargetForAction:action sender:sender];
}

- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation {
	if (!(self = [super initWithScrollView:scrollView orientation:orientation]))
		return nil;
	
	_clickedLineNumber = NSNotFound;
	
	return self;
}

- (void)setClientView:(NSView *)client {
	[super setClientView:client];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidFold:) name:WCSourceTextStorageDidFoldNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidUnfold:) name:WCSourceTextStorageDidUnfoldNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidAddBookmark:) name:WCSourceTextStorageDidAddBookmarkNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveBookmark:) name:WCSourceTextStorageDidRemoveBookmarkNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveAllBookmarks:) name:WCSourceTextStorageDidRemoveAllBookmarksNotification object:[self textStorage]];
}

- (NSArray *)lineStartIndexes {
	return [[self textStorage] lineStartIndexes];
}

static const CGFloat kIconWidthHeight = 11.0;
static const CGFloat kIconPaddingLeft = 1.0;
static const CGFloat kIconPaddingTop = 1.0;
static const CGFloat kCodeFoldingRibbonWidth = 8.0;
static const CGFloat kBuildIssueWidthHeight = 10.0;

- (void)mouseEntered:(NSEvent *)theEvent {
	NSRange range = [self _rangeForPoint:[self convertPointFromBase:[theEvent locationInWindow]]];
	WCFold *fold = [[[[self delegate] sourceScannerForSourceRulerView:self] folds] deepestFoldForRange:range];
	
	[self setFoldToHighlight:fold];
}
- (void)mouseExited:(NSEvent *)theEvent {
	[self setFoldToHighlight:nil];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	NSRange range = [self _rangeForPoint:[self convertPointFromBase:[theEvent locationInWindow]]];
	WCFold *fold = [[[[self delegate] sourceScannerForSourceRulerView:self] folds] deepestFoldForRange:range];
	
	[self setFoldToHighlight:fold];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self setDidReceiveMouseDown:YES];
    
	if ([self foldToHighlight]) {
		NSRange foldRange = [[self textStorage] foldRangeForRange:[[self foldToHighlight] contentRange]];
		// the range is folded, unfold it
		if (foldRange.location == NSNotFound)
			[[self textStorage] foldRange:[[self foldToHighlight] contentRange]];
		// otherwise the range isn't folded, fold it
		else
			[[self textStorage] unfoldRange:foldRange effectiveRange:NULL];
	}
	else {
		NSPoint point = [self convertPointFromBase:[theEvent locationInWindow]];
		NSRange range = [self _rangeForPoint:point];
		WCBuildIssue *buildIssue = [[[self delegate] buildIssuesForSourceRulerView:self] buildIssueForRange:range];
		
		if (buildIssue) {
			NSLayoutManager *layoutManager = [[self textView] layoutManager];
			NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:range.location] effectiveRange:NULL];
			NSRect buildIssueRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, kBuildIssueWidthHeight, kBuildIssueWidthHeight);
			
			if (NSMouseInRect(point, buildIssueRect, [self isFlipped])) {

				[self setClickedBuildIssue:buildIssue];
				[self setClickedFileBreakpoint:nil];
				return;
			}
		}
		
		WCFileBreakpoint *fileBreakpoint = [[[self delegate] fileBreakpointsForSourceRulerView:self] fileBreakpointForRange:range];
		
		if (!fileBreakpoint) {
			WCProjectDocument *projectDocument = [[self delegate] projectDocumentForSourceRulerView:self];
			WCFile *file = [[self delegate] fileForSourceRulerView:self];
			WCFileBreakpoint *fileBreakpoint = [WCFileBreakpoint fileBreakpointWithRange:range file:file projectDocument:projectDocument];
			
			[[projectDocument breakpointManager] addFileBreakpoint:fileBreakpoint];
		}
		
		[self setClickedBuildIssue:nil];
		[self setClickedFileBreakpoint:fileBreakpoint];
		[self setClickedFileBreakpointHasMoved:NO];
	}
}
- (void)mouseDragged:(NSEvent *)theEvent {
	if ([self clickedFileBreakpoint]) {
		NSPoint point = [self convertPointFromBase:[theEvent locationInWindow]];
		NSRange range = [self _rangeForPoint:point];
		WCFileBreakpoint *fileBreakpoint = [[[self delegate] fileBreakpointsForSourceRulerView:self] fileBreakpointForRange:range];
		
		if (!NSMouseInRect(point, [self bounds], [self isFlipped])) {
			[[NSCursor disappearingItemCursor] set];
			return;
		}
		
		[[NSCursor arrowCursor] set];
		
		if (fileBreakpoint == [self clickedFileBreakpoint])
			return;
		else if (fileBreakpoint)
			return;
		else {
			[self setClickedFileBreakpointHasMoved:YES];
			
			[[[self clickedFileBreakpoint] retain] autorelease];
			
			WCBreakpointManager *breakpointManager = [[[self delegate] projectDocumentForSourceRulerView:self] breakpointManager];
			
			[breakpointManager removeFileBreakpoint:[self clickedFileBreakpoint]];
			
			[[self clickedFileBreakpoint] setRange:range];
			
			[breakpointManager addFileBreakpoint:[self clickedFileBreakpoint]];
		}
	}
}
- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint point = [self convertPointFromBase:[theEvent locationInWindow]];
	NSRange range = [self _rangeForPoint:point];
	WCFileBreakpoint *fileBreakpoint = [[[self delegate] fileBreakpointsForSourceRulerView:self] fileBreakpointForRange:range];
	WCBuildIssue *buildIssue = [[[self delegate] buildIssuesForSourceRulerView:self] buildIssueForRange:range];
	
    if ([self didReceiveMouseDown]) {
        if (buildIssue && buildIssue == [self clickedBuildIssue])
            [buildIssue setVisible:(![buildIssue isVisible])];
        else if ([self clickedFileBreakpoint] && !NSMouseInRect(point, [self bounds], [self isFlipped]))
            NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, [[self window] convertBaseToScreen:[theEvent locationInWindow]], NSZeroSize, self, @selector(_animationEffectDidEnd:), NULL);
        else if (fileBreakpoint && fileBreakpoint == [self clickedFileBreakpoint] && ![self clickedFileBreakpointHasMoved])
            [fileBreakpoint setActive:(![fileBreakpoint isActive])];
    }
	else {
		[self setClickedBuildIssue:nil];
		[self setClickedFileBreakpoint:nil];
		[self setClickedLineNumber:NSNotFound];
	}
    
    [self setDidReceiveMouseDown:NO];
}
- (void)_animationEffectDidEnd:(void *)contextInfo {
	[[[[self delegate] projectDocumentForSourceRulerView:self] breakpointManager] removeFileBreakpoint:[self clickedFileBreakpoint]];
	
	[self setClickedBuildIssue:nil];
	[self setClickedFileBreakpoint:nil];
	[self setClickedLineNumber:NSNotFound];
	
	NSPoint point = [[[self window] contentView] convertPointFromBase:[[self window] convertScreenToBase:[NSEvent mouseLocation]]];
	NSView *view = [[[self window] contentView] hitTest:point];
	
	if (![view isEqual:[self clientView]])
		[[NSCursor arrowCursor] set];
}

- (void)updateTrackingAreas {
	[super updateTrackingAreas];
	
	[self _updateCodeFoldingTrackingArea];
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	
	[[RSToolTipManager sharedManager] removeView:self];
	
	if ([self window])
		[[RSToolTipManager sharedManager] addView:self];
}

- (CGFloat)minimumThickness {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey] &&
		[[self delegate] projectDocumentForSourceRulerView:self])
		return [super minimumThickness]+kBuildIssueWidthHeight+kIconPaddingLeft+kCodeFoldingRibbonWidth;
	else if ([[self delegate] projectDocumentForSourceRulerView:self])
		return [super minimumThickness]+kBuildIssueWidthHeight+kIconPaddingLeft;
	else if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft+kCodeFoldingRibbonWidth;
	return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft;
}

- (NSDictionary *)textAttributesForLineNumber:(NSUInteger)lineNumber selectedLineNumbers:(NSIndexSet *)selectedLineNumbers {
	NSUInteger lineStartIndex = [[[self lineStartIndexes] objectAtIndex:lineNumber] unsignedIntegerValue];
	WCFileBreakpoint *fileBreakpoint = [[[self delegate] fileBreakpointsForSourceRulerView:self] fileBreakpointForRange:NSMakeRange(lineStartIndex, 0)];
	
	if (fileBreakpoint && ![selectedLineNumbers containsIndex:lineNumber]) {
		NSMutableDictionary *textAttributes = [[[self textAttributes] mutableCopy] autorelease];
		
		[textAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		
		return textAttributes;
	}
	return [super textAttributesForLineNumber:lineNumber selectedLineNumbers:selectedLineNumbers];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
	[super drawBackgroundInRect:rect];
	
	[self drawCodeFoldingRibbonInRect:NSMakeRect(NSMaxX(rect)-kCodeFoldingRibbonWidth, NSMinY(rect), kCodeFoldingRibbonWidth, NSHeight(rect))];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		[super drawRightMarginInRect:NSMakeRect(NSMinX(rect), NSMinY(rect), NSWidth(rect)-kCodeFoldingRibbonWidth, NSHeight(rect))];
	else
		[super drawRightMarginInRect:rect];
	
	[self drawCurrentLineHighlightInRect:rect];
	
	[self drawFileBreakpointsInRect:rect];
	
	[self drawBuildIssuesInRect:rect];
	
	[self drawBookmarksInRect:rect];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		[self drawLineNumbersInRect:NSMakeRect(NSMinX(rect), NSMinY(rect), NSWidth(rect)-kCodeFoldingRibbonWidth, NSHeight(rect))];
	else
		[self drawLineNumbersInRect:rect];
}
- (NSSet *)userDefaultsKeyPathsToObserve {
	NSMutableSet *keys = [[[super userDefaultsKeyPathsToObserve] mutableCopy] autorelease];
	
	[keys unionSet:[NSSet setWithObjects:WCEditorShowCodeFoldingRibbonKey, nil]];
	
	return keys;
}
#pragma mark RSToolTipView
- (NSArray *)toolTipManager:(RSToolTipManager *)toolTipManager toolTipProvidersForToolTipAtPoint:(NSPoint)toolTipPoint {
	NSRange range = [self _rangeForPoint:toolTipPoint];	
	NSArray *buildIssues = [[[self delegate] buildIssuesForSourceRulerView:self] buildIssuesForRange:range];
	NSMutableArray *actualBuildIssues = [NSMutableArray arrayWithCapacity:[buildIssues count]];
	
	for (WCBuildIssue *buildIssue in buildIssues) {
		if ([buildIssue range].location == range.location)
			[actualBuildIssues addObject:buildIssue];
	}
	
	if ([actualBuildIssues count])
		return actualBuildIssues;
	return nil;
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingFormat:WCEditorShowCodeFoldingRibbonKey]]) {
		[self _updateCodeFoldingTrackingArea];
		[self setNeedsDisplay:YES];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(_toggleBookmark:)) {
		if ([[self textStorage] bookmarkAtLineNumber:[self clickedLineNumber]])
			[menuItem setTitle:NSLocalizedString(@"Remove Bookmark", @"Remove Bookmark")];
		else
			[menuItem setTitle:NSLocalizedString(@"Add Bookmark", @"Add Bookmark")];
		
		if ([self clickedLineNumber] == NSNotFound)
			return NO;
	}
	else if ([menuItem action] == @selector(_toggleBreakpoint:)) {
		if ([[self clickedFileBreakpoint] isActive])
			[menuItem setTitle:NSLocalizedString(@"Disable Breakpoint", @"Disable Breakpoint")];
		else
			[menuItem setTitle:NSLocalizedString(@"Enable Breakpoint", @"Enable Breakpoint")];
		
		if (![self clickedFileBreakpoint])
			return NO;
	}
	else if ([menuItem action] == @selector(_editBreakpoint:)) {
		if (![[self delegate] projectDocumentForSourceRulerView:self])
			return NO;
		
		if ([self clickedFileBreakpoint])
			[menuItem setTitle:NSLocalizedString(@"Edit Breakpoint", @"Edit Breakpoint")];
		else
			[menuItem setTitle:NSLocalizedString(@"Add Breakpoint", @"Add Breakpoint")];
	}
	else if ([menuItem action] == @selector(_deleteBreakpoint:)) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBreakpointsKey])
			[menuItem setTitle:NSLocalizedString(@"Delete Breakpoint\u2026", @"Delete Breakpoint with ellipsis")];
		else
			[menuItem setTitle:NSLocalizedString(@"Delete Breakpoint", @"Delete Breakpoint")];
		
		if (![self clickedFileBreakpoint])
			return NO;
	}
	else if ([menuItem action] == @selector(_revealInBreakpointNavigator:)) {
		if (![self clickedFileBreakpoint])
			return NO;
	}
	else if ([menuItem action] == @selector(_revealInIssueNavigator:)) {
		if (![self clickedBuildIssue])
			return NO;
	}
	else if ([menuItem action] == @selector(_toggleIssue:)) {
		if ([[self clickedBuildIssue] isVisible])
			[menuItem setTitle:NSLocalizedString(@"Hide Build Issue", @"Hide Build Issue")];
		else
			[menuItem setTitle:NSLocalizedString(@"Show Build Issue", @"Show Build Issue")];
		
		if (![self clickedBuildIssue])
			return NO;
	}
	return YES;
}
#pragma mark *** Public Methods ***

- (void)drawCodeFoldingRibbonInRect:(NSRect)ribbonRect; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return;
	
	[[NSColor colorWithCalibratedWhite:230.0/255.0 alpha:1.0] setFill];
	NSRectFill(ribbonRect);
	
	NSArray *folds = [[[[self delegate] sourceScannerForSourceRulerView:self] folds] foldsForRange:[[self textView] visibleRange]];
	NSColor *topLevelFoldColor = [NSColor colorWithCalibratedWhite:200.0/255.0 alpha:1.0];
	
	for (WCFold *fold in folds) {
		NSRange foldRange = [fold range];
		if (NSMaxRange(foldRange) >= [[[self textView] string] length])
			foldRange.length -= (NSMaxRange(foldRange) - [[[self textView] string] length]);
		
		NSRect foldRect = [self _rectForFold:fold inRect:ribbonRect];
		
		[topLevelFoldColor setFill];
		NSRectFill(foldRect);
		
		[self _drawFoldsForFold:fold inRect:ribbonRect topLevelFoldColor:topLevelFoldColor stepAmount:0.08 level:0];
	}
	
	if ([self foldToHighlight])
		[self _drawFoldHighlightInRect:ribbonRect];
	
	[super drawRightMarginInRect:ribbonRect];
}

- (void)drawBuildIssuesInRect:(NSRect)buildIssueRect; {
	NSArray *buildIssues = [[self delegate] buildIssuesForSourceRulerView:self];
	NSMutableIndexSet *errorIndexes = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *warningIndexes = [NSMutableIndexSet indexSet];
	
	for (WCBuildIssue *buildIssue in [buildIssues buildIssuesForRange:[[self textView] visibleRange]]) {
		switch ([buildIssue type]) {
			case WCBuildIssueTypeError:
				if ([errorIndexes containsIndex:[buildIssue range].location])
					continue; 
				else {
					NSUInteger rectCount;
					NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[buildIssue range]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];;
					
					if (!rectCount)
						continue;
					
					NSRect lineRect;
					
					if ([buildIssue isVisible]) {
						if (rectCount == 1)
							lineRect = rects[0];
						else {
							lineRect = NSZeroRect;
							NSUInteger rectIndex;
							for (rectIndex=0; rectIndex<rectCount; rectIndex++)
								lineRect = NSUnionRect(lineRect, rects[rectIndex]);
						}
						
						lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
						
						if (!NSIntersectsRect(lineRect, buildIssueRect) || ![self needsToDrawRect:lineRect])
							continue;
						
						[[WCBuildIssue errorSelectedFillGradient] drawInRect:lineRect angle:90.0];
						[[WCBuildIssue errorFillColor] setFill];
						NSRectFill(NSMakeRect(NSMinX(lineRect), NSMinY(lineRect), NSWidth(lineRect), 1.0));
						NSRectFill(NSMakeRect(NSMinX(lineRect), NSMaxY(lineRect)-1, NSWidth(lineRect), 1.0));
					}
					
					rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[buildIssue range] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
					
					lineRect = rects[0];
					
					lineRect = NSMakeRect(NSMinX(buildIssueRect)+kIconPaddingLeft, [self convertPoint:lineRect.origin fromView:[self clientView]].y+floor((NSHeight(lineRect)-kBuildIssueWidthHeight)/2.0), kBuildIssueWidthHeight, kBuildIssueWidthHeight);
					
					[(NSImage *)[NSImage imageNamed:@"Error"] drawInRect:lineRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
					
					[errorIndexes addIndex:[buildIssue range].location];
				}
				break;
			case WCBuildIssueTypeWarning:
				if ([errorIndexes containsIndex:[buildIssue range].location] ||
					[warningIndexes containsIndex:[buildIssue range].location])
					continue;
				else {
					NSUInteger rectCount;
					NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[buildIssue range]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];;
					
					if (!rectCount)
						continue;
					
					NSRect lineRect;
					
					if ([buildIssue isVisible]) {
						if (rectCount == 1)
							lineRect = rects[0];
						else {
							lineRect = NSZeroRect;
							NSUInteger rectIndex;
							for (rectIndex=0; rectIndex<rectCount; rectIndex++)
								lineRect = NSUnionRect(lineRect, rects[rectIndex]);
						}
						
						lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
						
						if (!NSIntersectsRect(lineRect, buildIssueRect) || ![self needsToDrawRect:lineRect])
							continue;
						
						[[WCBuildIssue warningSelectedFillGradient] drawInRect:lineRect angle:90.0];
						[[WCBuildIssue warningFillColor] setFill];
						NSRectFill(NSMakeRect(NSMinX(lineRect), NSMinY(lineRect), NSWidth(lineRect), 1.0));
						NSRectFill(NSMakeRect(NSMinX(lineRect), NSMaxY(lineRect)-1, NSWidth(lineRect), 1.0));
					}
					
					rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[buildIssue range] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
					
					lineRect = rects[0];
					
					lineRect = NSMakeRect(NSMinX(buildIssueRect)+kIconPaddingLeft, [self convertPoint:lineRect.origin fromView:[self clientView]].y+floor((NSHeight(lineRect)-kBuildIssueWidthHeight)/2.0), kBuildIssueWidthHeight, kBuildIssueWidthHeight);
					
					[(NSImage *)[NSImage imageNamed:@"Warning"] drawInRect:lineRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
					
					[warningIndexes addIndex:[buildIssue range].location];
				}
				break;
			default:
				break;
		}
	}
	
	NSMutableIndexSet *buildIssueLineStartIndexes = [NSMutableIndexSet indexSet];
	
	[buildIssueLineStartIndexes addIndexes:errorIndexes];
	[buildIssueLineStartIndexes addIndexes:warningIndexes];
	
	[self setLineStartIndexesWithBuildIssues:buildIssueLineStartIndexes];
}

- (void)drawFileBreakpointsInRect:(NSRect)breakpointRect; {
	NSArray *fileBreakpoints = [[self delegate] fileBreakpointsForSourceRulerView:self];
	
	for (WCFileBreakpoint *fileBreakpoint in [fileBreakpoints fileBreakpointsForRange:[[self textView] visibleRange]]) {		
		NSRect lineRect = [[[self textView] layoutManager] lineFragmentRectForGlyphAtIndex:[[[self textView] layoutManager] glyphIndexForCharacterAtIndex:[fileBreakpoint range].location] effectiveRange:NULL];
		
		lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
		
		if (!NSIntersectsRect(lineRect, breakpointRect) || ![self needsToDrawRect:lineRect])
			continue;
		
		lineRect = NSInsetRect(lineRect, 1.0, 0.0);
		
		NSImage *breakpointIcon = [WCBreakpoint breakpointIconWithSize:NSMakeSize(NSWidth(lineRect), NSHeight(lineRect)) type:[fileBreakpoint type] active:[fileBreakpoint isActive] enabled:[[[fileBreakpoint projectDocument] breakpointManager] breakpointsEnabled]];
		
		[breakpointIcon drawInRect:lineRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
}

- (void)drawBookmarksInRect:(NSRect)bookmarkRect; {
	for (RSBookmark *bookmark in [[self textStorage] bookmarksForRange:[[self textView] visibleRange]]) {
		if ([[self lineStartIndexesWithBuildIssues] containsIndex:[[self lineStartIndexes] lineStartIndexForRange:[bookmark range]]])
			continue;
		
		NSRect lineRect = [[[self textView] layoutManager] lineFragmentRectForGlyphAtIndex:[[[self textView] layoutManager] glyphIndexForCharacterAtIndex:[bookmark range].location] effectiveRange:NULL];
		
		lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
		
		if (!NSIntersectsRect(lineRect, bookmarkRect) || ![self needsToDrawRect:lineRect])
			continue;
		
		NSImage *bookmarkImage = [NSImage imageNamed:@"Bookmark"];
		NSRect bookmarkRect = NSMakeRect(NSMinX(lineRect)+kIconPaddingLeft, NSMinY(lineRect)+kIconPaddingTop, kIconWidthHeight, kIconWidthHeight);
		
		[bookmarkImage drawInRect:bookmarkRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
}
#pragma mark Properties
@dynamic textStorage;
- (WCSourceTextStorage *)textStorage {
	return (WCSourceTextStorage *)[[self textView] textStorage];
}

@synthesize clickedLineNumber=_clickedLineNumber;
@synthesize delegate=_delegate;
- (void)setDelegate:(id<WCSourceRulerViewDelegate>)delegate {
	if (_delegate == delegate)
		return;
	
	_delegate = delegate;
	
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningFolds:) name:WCSourceScannerDidFinishScanningFoldsNotification object:[_delegate sourceScannerForSourceRulerView:self]];
		
		WCProjectDocument *projectDocument = [_delegate projectDocumentForSourceRulerView:self];
		
		if (projectDocument) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:[projectDocument buildController]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidChangeBuildIssueVisible:) name:WCBuildControllerDidChangeBuildIssueVisibleNotification object:[projectDocument buildController]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidChangeAllBuildIssuesVisible:) name:WCBuildControllerDidChangeAllBuildIssuesVisibleNotification object:[projectDocument buildController]];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidAddFileBreakpoint:) name:WCBreakpointManagerDidAddFileBreakpointNotification object:[projectDocument breakpointManager]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidRemoveFileBreakpoint:) name:WCBreakpointManagerDidRemoveFileBreakpointNotification object:[projectDocument breakpointManager]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidChangeBreakpointActive:) name:WCBreakpointManagerDidChangeBreakpointActiveNotification object:[projectDocument breakpointManager]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidChangeBreakpointsEnabled:) name:WCBreakpointManagerDidChangeBreakpointsEnabledNotification object:[projectDocument breakpointManager]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontAndColorThemeManagerCurrentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontAndColorThemeManagerColorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontAndColorThemeManagerFontDidChange:) name:WCFontAndColorThemeManagerFontDidChangeNotification object:nil];
		}
	}
}
@dynamic sourceTextView;
- (WCSourceTextView *)sourceTextView {
	return (WCSourceTextView *)[self textView];
}
@synthesize foldToHighlight=_foldToHighlight;
- (void)setFoldToHighlight:(WCFold *)foldToHighlight {
	_foldToHighlight = foldToHighlight;
	
	[self setNeedsDisplay:YES];
}
@synthesize clickedFileBreakpoint=_clickedFileBreakpoint;
@synthesize didReceiveMouseDown=_didReceiveMouseDown;
@synthesize clickedBuildIssue=_clickedBuildIssue;
@dynamic clickedFileBreakpointHasMoved;
- (BOOL)clickedFileBreakpointHasMoved {
	return _sourceRulerViewFlags.clickedFileBreakpointHasMoved;
}
- (void)setClickedFileBreakpointHasMoved:(BOOL)clickedFileBreakpointHasMoved {
	_sourceRulerViewFlags.clickedFileBreakpointHasMoved = clickedFileBreakpointHasMoved;
}
@dynamic editBreakpointViewController;
- (WCEditBreakpointViewController *)editBreakpointViewController {
	if (!_editBreakpointViewController)
		_editBreakpointViewController = [[WCEditBreakpointViewController alloc] initWithBreakpoint:nil];
	return _editBreakpointViewController;
}
@synthesize lineStartIndexesWithBuildIssues=_lineStartIndexesWithBuildIssues;
#pragma mark *** Private Methods ***
- (NSUInteger)_lineNumberForPoint:(NSPoint)point {
	NSLayoutManager *layoutManager = [[self textView] layoutManager];
	NSTextContainer	*container = [[self textView] textContainer];
	NSRange	glyphRange = [layoutManager glyphRangeForBoundingRect:[[self clientView] visibleRect] inTextContainer:container];
	NSRange range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	NSUInteger lineNumber, lineStartIndex, numberOfLines = [[self lineStartIndexes] count];
	
	// Fudge the range a tad in case there is an extra new line at end.
	// It doesn't show up in the glyphs so would not be accounted for.
	range.length++;
	
	for (lineNumber = [[self lineStartIndexes] lineNumberForRange:range]; lineNumber < numberOfLines; lineNumber++) {
		lineStartIndex = [[[self lineStartIndexes] objectAtIndex:lineNumber] unsignedIntegerValue];
		
		if (NSLocationInRange(lineStartIndex, range)) {
			NSUInteger rectCount;
			NSRectArray rects = [layoutManager rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:NSMakeRange(lineStartIndex, 0)] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:container rectCount:&rectCount];
			
			if (rectCount) {
				NSRect lineRect;
				
				if (rectCount == 1)
					lineRect = rects[0];
				else {
					lineRect = NSZeroRect;
					NSUInteger rectIndex;
					for (rectIndex = 0; rectIndex < rectCount; rectIndex++)
						lineRect = NSUnionRect(lineRect, rects[rectIndex]);
				}
				
				lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
				
				if ((point.y >= NSMinY(lineRect)) && (point.y < NSMaxY(lineRect)))
					return lineNumber;
			}
		}
		
		if (lineStartIndex > NSMaxRange(range))
			break;
	}
	return NSNotFound;
}

- (NSRange)_rangeForPoint:(NSPoint)point; {
	NSLayoutManager *layoutManager = [[self textView] layoutManager];
	NSTextContainer	*container = [[self textView] textContainer];
	NSRange	glyphRange = [layoutManager glyphRangeForBoundingRect:[[self clientView] visibleRect] inTextContainer:container];
	NSRange range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	NSUInteger lineNumber, lineStartIndex, numberOfLines = [[self lineStartIndexes] count];
	
	// Fudge the range a tad in case there is an extra new line at end.
	// It doesn't show up in the glyphs so would not be accounted for.
	range.length++;
	
	for (lineNumber = [[self lineStartIndexes] lineNumberForRange:range]; lineNumber < numberOfLines; lineNumber++) {
		lineStartIndex = [[[self lineStartIndexes] objectAtIndex:lineNumber] unsignedIntegerValue];
		
		if (NSLocationInRange(lineStartIndex, range)) {
			NSUInteger rectCount;
			NSRectArray rects = [layoutManager rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:NSMakeRange(lineStartIndex, 0)] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:container rectCount:&rectCount];
			
			if (rectCount) {
				NSRect lineRect;
				
				if (rectCount == 1)
					lineRect = rects[0];
				else {
					lineRect = NSZeroRect;
					NSUInteger rectIndex;
					for (rectIndex = 0; rectIndex < rectCount; rectIndex++)
						lineRect = NSUnionRect(lineRect, rects[rectIndex]);
				}
				
				lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
				
				if ((point.y >= NSMinY(lineRect)) && (point.y < NSMaxY(lineRect)))
					return NSMakeRange(lineStartIndex, 0);
			}
		}
		
		if (lineStartIndex > NSMaxRange(range))
			break;
	}
	return NSNotFoundRange;
}

- (void)_drawFoldsForFold:(WCFold *)fold inRect:(NSRect)ribbonRect topLevelFoldColor:(NSColor *)topLevelFoldColor stepAmount:(CGFloat)stepAmount level:(NSUInteger)level; {
	NSColor *colorForThisFoldLevel = nil;
	
	for (WCFold *childFold in [fold childNodes]) {
		NSRect foldRect = [self _rectForFold:childFold inRect:ribbonRect];
		
		if (!colorForThisFoldLevel)
			colorForThisFoldLevel = [topLevelFoldColor darkenBy:stepAmount*((CGFloat)++level)];
		
		[colorForThisFoldLevel setFill];
		NSRectFill(foldRect);
		
		[self _drawFoldsForFold:childFold inRect:ribbonRect topLevelFoldColor:topLevelFoldColor stepAmount:stepAmount level:level];
	}
}

static const CGFloat kTriangleHeight = 6.0;
- (void)_drawFoldHighlightInRect:(NSRect)ribbonRect; {
#ifdef DEBUG
    NSAssert(_foldToHighlight, @"_foldToHighlight cannot be nil!");
#endif
	
	NSRect foldHighlightRect = [self _rectForFold:[self foldToHighlight] inRect:ribbonRect];
	
	[[NSColor whiteColor] setFill];
	NSRectFill(foldHighlightRect);
	
	foldHighlightRect = NSInsetRect(foldHighlightRect, 1.0, 1.0);
	foldHighlightRect = NSOffsetRect(foldHighlightRect, -0.5, 0.0);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[[self textStorage] setLineFoldingEnabled:YES];
	
	NSRange foldRange = [[[self sourceTextView] sourceTextStorage] foldRangeForRange:[_foldToHighlight contentRange]];
	if (foldRange.location == NSNotFound) {		
		[path moveToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMaxX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect)+floor(NSWidth(foldHighlightRect)/2.0), NSMinY(foldHighlightRect)+kTriangleHeight)];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path closePath];
		
		[path moveToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMaxY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMaxX(foldHighlightRect), NSMaxY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect)+floor(NSWidth(foldHighlightRect)/2.0), NSMaxY(foldHighlightRect)-kTriangleHeight)];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMaxY(foldHighlightRect))];
		[path closePath];
		
		[[NSColor darkGrayColor] setFill];
		[path fill];
		
		[self _drawFoldsForFold:[self foldToHighlight] inRect:ribbonRect topLevelFoldColor:[NSColor whiteColor] stepAmount:0.12 level:0];
	}
	else {
		[path moveToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMaxY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect)+NSWidth(foldHighlightRect), NSMinY(foldHighlightRect)+kTriangleHeight)];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path closePath];
		
		[[NSColor darkGrayColor] setFill];
		[path fill];
	}
	
	[[self textStorage] setLineFoldingEnabled:NO];
}

- (void)_updateCodeFoldingTrackingArea; {	
	[self removeTrackingArea:_codeFoldingTrackingArea];
	[_codeFoldingTrackingArea release];
	_codeFoldingTrackingArea = nil;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey]) {
		NSView *contentView = [[self window] contentView];
		BOOL assumeInside = ([contentView hitTest:[contentView convertPointFromBase:[[contentView window] convertScreenToBase:[NSEvent mouseLocation]]]] == self);
		NSTrackingAreaOptions options = (NSTrackingActiveInKeyWindow|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited);
		if (assumeInside)
			options |= NSTrackingAssumeInside;
		_codeFoldingTrackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(NSMaxX([self bounds])-kCodeFoldingRibbonWidth, NSMinY([self bounds]), kCodeFoldingRibbonWidth, NSHeight([self bounds])) options:options owner:self userInfo:nil];
		[self addTrackingArea:_codeFoldingTrackingArea];
	}
}
- (NSRect)_rectForFold:(WCFold *)fold inRect:(NSRect)ribbonRect; {
	NSRange foldRange = [fold range];
	if (NSMaxRange(foldRange) >= [[[self textView] string] length])
		foldRange.length -= (NSMaxRange(foldRange) - [[[self textView] string] length]);
	
	NSUInteger rectCount;
	NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:foldRange withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
	
	if (!rectCount)
		return NSZeroRect;
	
	NSRect foldRect = NSZeroRect;
	NSUInteger rectIndex;
	for (rectIndex=0; rectIndex<rectCount; rectIndex++)
		foldRect = NSUnionRect(foldRect, rects[rectIndex]);
	
	return NSMakeRect(NSMinX(ribbonRect), [self convertPoint:foldRect.origin fromView:[self clientView]].y, NSWidth(ribbonRect), NSHeight(foldRect));
}
#pragma mark IBActions
- (IBAction)_toggleBookmark:(id)sender; {
	RSBookmark *bookmark = [[self textStorage] bookmarkAtLineNumber:[self clickedLineNumber]];
	
	if (bookmark)
		[[self textStorage] removeBookmark:bookmark];
	else {
		bookmark = [RSBookmark bookmarkWithRange:NSMakeRange([[[self textView] string] rangeForLineNumber:[self clickedLineNumber]].location, 0) visibleRange:NSEmptyRange textStorage:[self textStorage]];
		[[self textStorage] addBookmark:bookmark];
	}
}
- (IBAction)_editBreakpoint:(id)sender {
	if ([self clickedFileBreakpoint]) {
		NSLayoutManager *layoutManager = [[self textView] layoutManager];
		NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:[[self clickedFileBreakpoint] range].location] effectiveRange:NULL];
		
		lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
		
		[[self editBreakpointViewController] setBreakpoint:[self clickedFileBreakpoint]];
		[[self editBreakpointViewController] showEditBreakpointViewRelativeToRect:lineRect ofView:self preferredEdge:NSMaxXEdge];
	}
	else {
		NSUInteger lineStartIndex = [[[self lineStartIndexes] objectAtIndex:[self clickedLineNumber]] unsignedIntegerValue];
		WCFileBreakpoint *fileBreakpoint = [WCFileBreakpoint fileBreakpointWithRange:NSMakeRange(lineStartIndex, 0) file:[[self delegate] fileForSourceRulerView:self] projectDocument:[[self delegate] projectDocumentForSourceRulerView:self]];
		
		[[[[self delegate] projectDocumentForSourceRulerView:self] breakpointManager] addFileBreakpoint:fileBreakpoint];
	}
}
- (IBAction)_toggleBreakpoint:(id)sender {
	[[self clickedFileBreakpoint] setActive:(![[self clickedFileBreakpoint] isActive])];
}
- (IBAction)_deleteBreakpoint:(id)sender {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBreakpointsKey]) {
		NSAlert *deleteBreakpointAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Delete Breakpoint?", @"Delete Breakpoint?") defaultButton:LOCALIZED_STRING_DELETE alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure you want to delete the selected breakpoint? This operation cannot be undone.", @"Are you sure you want to delete the selected breakpoint? This operation cannot be undone.")];
		
		[deleteBreakpointAlert setShowsSuppressionButton:YES];
		
		[[deleteBreakpointAlert suppressionButton] bind:NSValueBinding toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:WCAlertsWarnBeforeDeletingBreakpointsKey] options:[NSDictionary dictionaryWithObjectsAndKeys:NSNegateBooleanTransformerName,NSValueTransformerNameBindingOption, nil]];
		
		[deleteBreakpointAlert OA_beginSheetModalForWindow:[self window] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert suppressionButton] unbind:NSValueBinding];
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[[[self delegate] projectDocumentForSourceRulerView:self] breakpointManager] removeFileBreakpoint:[self clickedFileBreakpoint]];
		}];
	}
	else
		[[[[self delegate] projectDocumentForSourceRulerView:self] breakpointManager] removeFileBreakpoint:[self clickedFileBreakpoint]];
}
- (IBAction)_toggleIssue:(id)sender {
	[[self clickedBuildIssue] setVisible:(![[self clickedBuildIssue] isVisible])];
}
- (IBAction)_revealInBreakpointNavigator:(id)sender {
	WCProjectDocument *projectDocument = [[self delegate] projectDocumentForSourceRulerView:self];
	
	[[[projectDocument projectWindowController] navigatorControl] setSelectedItemIdentifier:@"breakpoint"];
	[[[projectDocument projectWindowController] breakpointNavigatorViewController] setSelectedModelObjects:[NSArray arrayWithObjects:[self clickedFileBreakpoint], nil]];
}
- (IBAction)_revealInIssueNavigator:(id)sender {
	WCProjectDocument *projectDocument = [[self delegate] projectDocumentForSourceRulerView:self];
	
	[[[projectDocument projectWindowController] navigatorControl] setSelectedItemIdentifier:@"issue"];
	[[[projectDocument projectWindowController] issueNavigatorViewController] setSelectedModelObjects:[NSArray arrayWithObjects:[self clickedBuildIssue], nil]];
}
#pragma mark Notifications
- (void)_sourceScannerDidFinishScanningFolds:(NSNotification *)note {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return;
	
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidFold:(NSNotification *)note {
	[self setFoldToHighlight:nil];
}
- (void)_textStorageDidUnfold:(NSNotification *)note {
	[self setFoldToHighlight:nil];
}
- (void)_textStorageDidAddBookmark:(NSNotification *)note {
	// TODO: should check to see if the bookmark is in our visibleRect before asking for redisplay
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidRemoveBookmark:(NSNotification *)note {
	// TODO: should check to see if the bookmark is in our visibleRect before asking for redisplay
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidRemoveAllBookmarks:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_buildControllerDidFinishBuilding:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_buildControllerDidChangeBuildIssueVisible:(NSNotification *)note {
	WCBuildIssue *buildIssue = [[note userInfo] objectForKey:WCBuildControllerDidChangeBuildIssueVisibleChangedBuildIssueUserInfoKey];
	
	if (NSLocationInOrEqualToRange([buildIssue range].location, [[self textView] visibleRange]))
		[self setNeedsDisplay:YES];
}
- (void)_buildControllerDidChangeAllBuildIssuesVisible:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}

- (void)_breakpointManagerDidAddFileBreakpoint:(NSNotification *)note {
	WCFileBreakpoint *fileBreakpoint = [[note userInfo] objectForKey:WCBreakpointManagerDidAddFileBreakpointNewFileBreakpointUserInfoKey];
	
	if (NSLocationInOrEqualToRange([fileBreakpoint range].location, [[self textView] visibleRange]))
		[self setNeedsDisplay:YES];
}
- (void)_breakpointManagerDidRemoveFileBreakpoint:(NSNotification *)note {
	WCFileBreakpoint *fileBreakpoint = [[note userInfo] objectForKey:WCBreakpointManagerDidRemoveFileBreakpointOldFileBreakpointUserInfoKey];
	
	if (NSLocationInOrEqualToRange([fileBreakpoint range].location, [[self textView] visibleRange]))
		[self setNeedsDisplay:YES];
}
- (void)_breakpointManagerDidChangeBreakpointActive:(NSNotification *)note {
	WCFileBreakpoint *fileBreakpoint = [[note userInfo] objectForKey:WCBreakpointManagerDidChangeBreakpointActiveChangedBreakpointUserInfoKey];
	
	if (NSLocationInOrEqualToRange([fileBreakpoint range].location, [[self textView] visibleRange]))
		[self setNeedsDisplay:YES];
}
- (void)_breakpointManagerDidChangeBreakpointsEnabled:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_fontAndColorThemeManagerCurrentThemeDidChange:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_fontAndColorThemeManagerColorDidChange:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_fontAndColorThemeManagerFontDidChange:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
@end
