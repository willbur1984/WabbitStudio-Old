//
//  WCSourceRulerView.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
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

@interface WCSourceRulerView ()
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@property (readwrite,assign,nonatomic) NSUInteger clickedLineNumber;

- (NSUInteger)_lineNumberForPoint:(NSPoint)point;
- (NSRange)_rangeForPoint:(NSPoint)point;
- (void)_drawFoldsForFold:(WCFold *)fold inRect:(NSRect)ribbonRect topLevelFoldColor:(NSColor *)topLevelFoldColor;
- (void)_drawFoldHighlightInRect:(NSRect)foldHighlightRect;
- (void)_updateCodeFoldingTrackingArea;
@end

@implementation WCSourceRulerView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_foldToHighlight = nil;
	[_codeFoldingTrackingArea release];
	[super dealloc];
}

+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:@"" action:@selector(_toggleBookmark:) keyEquivalent:@""];
	});
	return retval;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSMenu *retval = [super menuForEvent:event];
	
	if (retval) {
		NSUInteger lineNumber = [self _lineNumberForPoint:[self convertPointFromBase:[event locationInWindow]]];
		
		[self setClickedLineNumber:lineNumber];
	}
	
	return retval;
}

- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation {
	if (!(self = [super initWithScrollView:scrollView orientation:orientation]))
		return nil;
	
	_clickedLineNumber = NSNotFound;
	
	return self;
}

- (void)setClientView:(NSView *)client {
	[super setClientView:client];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidAddBookmark:) name:WCSourceTextStorageDidAddBookmarkNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveBookmark:) name:WCSourceTextStorageDidRemoveBookmarkNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveAllBookmarks:) name:WCSourceTextStorageDidRemoveAllBookmarksNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidFold:) name:WCSourceTextStorageDidFoldNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidUnfold:) name:WCSourceTextStorageDidUnfoldNotification object:[self textStorage]];
}

- (NSArray *)lineStartIndexes {
	return [[self textStorage] lineStartIndexes];
}

static const CGFloat kIconWidthHeight = 12.0;
static const CGFloat kIconPaddingLeft = 1.0;
static const CGFloat kIconPaddingTop = 1.0;
static const CGFloat kCodeFoldingRibbonWidth = 8.0;

- (void)mouseEntered:(NSEvent *)theEvent {
	NSRange range = [self _rangeForPoint:[self convertPointFromBase:[theEvent locationInWindow]]];
	WCFold *fold = [[[[self delegate] sourceScannerForSourceRulerView:self] folds] deepestFoldForRange:range];
	
	_foldToHighlight = fold;
	if (_foldToHighlight) {
		//[[self textView] showFindIndicatorForRange:[fold contentRange]];
		[self setNeedsDisplay:YES];
	}
}
- (void)mouseExited:(NSEvent *)theEvent {
	_foldToHighlight = nil;
	[self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	NSRange range = [self _rangeForPoint:[self convertPointFromBase:[theEvent locationInWindow]]];
	WCFold *fold = [[[[self delegate] sourceScannerForSourceRulerView:self] folds] deepestFoldForRange:range];
	
	if (fold) {
		if (_foldToHighlight != fold) {
			_foldToHighlight = fold;
			//[[self textView] showFindIndicatorForRange:[fold contentRange]];
			[self setNeedsDisplay:YES];
		}
	}
	else if (_foldToHighlight) {
		_foldToHighlight = nil;
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (_foldToHighlight) {
		NSRange foldRange = [[self textStorage] foldRangeForRange:[_foldToHighlight contentRange]];
		// the range is folded, unfold it
		if (foldRange.location == NSNotFound)
			[[self textStorage] foldRange:[_foldToHighlight contentRange]];
		// otherwise the range isn't folded, fold it
		else
			[[self textStorage] unfoldRange:foldRange effectiveRange:NULL];
	}
	/*
	else {
		NSUInteger lineNumber = [self _lineNumberForPoint:[self convertPointFromBase:[theEvent locationInWindow]]];
		
		if (lineNumber != NSNotFound) {
			RSBookmark *bookmark = [[[self sourceTextView] sourceTextStorage] bookmarkAtLineNumber:lineNumber];
			
			if (bookmark)
				[[[self sourceTextView] sourceTextStorage] removeBookmark:bookmark];
			else
				[[[self sourceTextView] sourceTextStorage] addBookmark:[RSBookmark bookmarkWithRange:NSMakeRange([[[self textView] string] rangeForLineNumber:lineNumber].location, 0) visibleRange:NSEmptyRange textStorage:[self textStorage]]];
		}
	}
	 */
}

- (void)updateTrackingAreas {
	[super updateTrackingAreas];
	
	[self _updateCodeFoldingTrackingArea];
}

- (CGFloat)minimumThickness {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft+kCodeFoldingRibbonWidth;
	return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
	[super drawBackgroundInRect:rect];
	
	[self drawCodeFoldingRibbonInRect:NSMakeRect(NSMaxX(rect)-kCodeFoldingRibbonWidth, NSMinY(rect), kCodeFoldingRibbonWidth, NSHeight(rect))];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		[super drawRightMarginInRect:NSMakeRect(NSMinX(rect), NSMinY(rect), NSWidth(rect)-kCodeFoldingRibbonWidth, NSHeight(rect))];
	else
		[super drawRightMarginInRect:rect];
	
	[super drawCurrentLineHighlightInRect:rect];
	
	[self drawBookmarksInRect:rect];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		[super drawLineNumbersInRect:NSMakeRect(NSMinX(rect), NSMinY(rect), NSWidth(rect)-kCodeFoldingRibbonWidth, NSHeight(rect))];
	else
		[super drawLineNumbersInRect:rect];
}
- (NSSet *)userDefaultsKeyPathsToObserve {
	NSMutableSet *keys = [[[super userDefaultsKeyPathsToObserve] mutableCopy] autorelease];
	
	[keys unionSet:[NSSet setWithObjects:WCEditorShowCodeFoldingRibbonKey, nil]];
	
	return keys;
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
	return YES;
}
#pragma mark *** Public Methods ***
- (void)drawBookmarksInRect:(NSRect)rect; {
	for (RSBookmark *bookmark in [[self textStorage] bookmarksForRange:[[self textView] visibleRange]]) {
		NSUInteger numRects;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[bookmark range]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
		
		if (!numRects)
			continue;
		
		NSRect bookmarkRect = rects[0];
		bookmarkRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:bookmarkRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(bookmarkRect));
		bookmarkRect = NSInsetRect(bookmarkRect, 1.0, 0.0);
		
		NSImage *bookmarkImage = [NSImage imageNamed:@"flag_green"];
		
		[bookmarkImage drawInRect:NSMakeRect(NSMinX(bookmarkRect)+kIconPaddingLeft, NSMinY(bookmarkRect), kIconWidthHeight, kIconWidthHeight) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
}

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
		
		NSUInteger rectCount;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:foldRange withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
		
		if (!rectCount)
			continue;
		
		NSRect foldRect = NSZeroRect;
		NSUInteger rectIndex;
		for (rectIndex=0; rectIndex<rectCount; rectIndex++)
			foldRect = NSUnionRect(foldRect, rects[rectIndex]);
		
		foldRect = NSMakeRect(NSMinX(ribbonRect), [self convertPoint:foldRect.origin fromView:[self clientView]].y, NSWidth(ribbonRect), NSHeight(foldRect));
		
		if (_foldToHighlight == fold)
			_rectForFoldHighlight = foldRect;
		
		[topLevelFoldColor setFill];
		NSRectFill(foldRect);
		
		[self _drawFoldsForFold:fold inRect:ribbonRect topLevelFoldColor:topLevelFoldColor];
	}
	
	if (_foldToHighlight)
		[self _drawFoldHighlightInRect:_rectForFoldHighlight];
	
	[super drawRightMarginInRect:ribbonRect];
}
#pragma mark Properties
@dynamic textStorage;
- (WCSourceTextStorage *)textStorage {
	return (WCSourceTextStorage *)[[self textView] textStorage];
}

@synthesize clickedLineNumber=_clickedLineNumber;
@dynamic delegate;
- (id<WCSourceRulerViewDelegate>)delegate {
	return _delegate;
}
- (void)setDelegate:(id<WCSourceRulerViewDelegate>)delegate {
	if (_delegate == delegate)
		return;
	
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCSourceScannerDidFinishScanningFoldsNotification object:nil];
	}
	
	_delegate = delegate;
	
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningFolds:) name:WCSourceScannerDidFinishScanningFoldsNotification object:[_delegate sourceScannerForSourceRulerView:self]];
	}
}
@dynamic sourceTextView;
- (WCSourceTextView *)sourceTextView {
	return (WCSourceTextView *)[self textView];
}
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

- (void)_drawFoldsForFold:(WCFold *)fold inRect:(NSRect)ribbonRect topLevelFoldColor:(NSColor *)topLevelFoldColor; {
	static const CGFloat stepAmount = 0.05;
	NSColor *colorForThisFoldLevel = nil;
	
	for (WCFold *childFold in [fold childNodes]) {
		NSRange foldRange = [childFold range];
		if (NSMaxRange(foldRange) >= [[[self textView] string] length])
			foldRange.length -= (NSMaxRange(foldRange) - [[[self textView] string] length]);
		
		NSUInteger rectCount;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:foldRange withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
		
		if (!rectCount)
			continue;
		
		NSRect foldRect = NSZeroRect;
		NSUInteger rectIndex;
		for (rectIndex=0; rectIndex<rectCount; rectIndex++)
			foldRect = NSUnionRect(foldRect, rects[rectIndex]);
		
		foldRect = NSMakeRect(NSMinX(ribbonRect), [self convertPoint:foldRect.origin fromView:[self clientView]].y, NSWidth(ribbonRect), NSHeight(foldRect));
		
		if (_foldToHighlight == childFold)
			_rectForFoldHighlight = foldRect;
		
		if (!colorForThisFoldLevel)
			colorForThisFoldLevel = [topLevelFoldColor darkenBy:stepAmount*((CGFloat)[childFold level])];
		
		[colorForThisFoldLevel setFill];
		NSRectFill(foldRect);
		
		[self _drawFoldsForFold:childFold inRect:ribbonRect topLevelFoldColor:topLevelFoldColor];
	}
}

static const CGFloat kTriangleHeight = 6.0;
- (void)_drawFoldHighlightInRect:(NSRect)foldHighlightRect; {
	[[NSColor whiteColor] setFill];
	NSRectFill(foldHighlightRect);
	
	foldHighlightRect = NSInsetRect(foldHighlightRect, 1.0, 1.0);
	foldHighlightRect = NSOffsetRect(foldHighlightRect, -0.5, 0.0);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[[self textStorage] setLineFoldingEnabled:YES];
	
	NSTextAttachment *attachment = [[self textStorage] attribute:NSAttachmentAttributeName atIndex:[_foldToHighlight contentRange].location effectiveRange:NULL];
	if ([[attachment attachmentCell] isKindOfClass:[WCFoldAttachmentCell class]]) {		
		[path moveToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMaxY(foldHighlightRect))];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect)+NSWidth(foldHighlightRect), NSMinY(foldHighlightRect)+kTriangleHeight)];
		[path lineToPoint:NSMakePoint(NSMinX(foldHighlightRect), NSMinY(foldHighlightRect))];
		[path closePath];
	}
	else {
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
	}
	
	[[self textStorage] setLineFoldingEnabled:NO];
	
	[[NSColor darkGrayColor] setFill];
	[path fill];
}

- (void)_updateCodeFoldingTrackingArea; {	
	[self removeTrackingArea:_codeFoldingTrackingArea];
	[_codeFoldingTrackingArea release];
	_codeFoldingTrackingArea = nil;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey]) {
		_codeFoldingTrackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(NSMaxX([self bounds])-kCodeFoldingRibbonWidth, NSMinY([self bounds]), kCodeFoldingRibbonWidth, NSHeight([self bounds])) options:NSTrackingActiveInKeyWindow|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
		[self addTrackingArea:_codeFoldingTrackingArea];
	}
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
#pragma mark Notifications
- (void)_textStorageDidAddBookmark:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidRemoveBookmark:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidRemoveAllBookmarks:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_sourceScannerDidFinishScanningFolds:(NSNotification *)note {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return;
	
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidFold:(NSNotification *)note {
	_foldToHighlight = nil;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		[self setNeedsDisplay:YES];
}
- (void)_textStorageDidUnfold:(NSNotification *)note {
	_foldToHighlight = nil;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		[self setNeedsDisplay:YES];
}
@end
