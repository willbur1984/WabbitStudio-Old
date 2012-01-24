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

@interface WCSourceRulerView ()
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@property (readwrite,assign,nonatomic) NSUInteger clickedLineNumber;

- (NSUInteger)_lineNumberForPoint:(NSPoint)point;
- (void)_drawFoldsForFold:(WCFold *)fold inRect:(NSRect)ribbonRect topLevelFoldColor:(NSColor *)topLevelFoldColor;
@end

@implementation WCSourceRulerView
#pragma mark *** Subclass Overrides ***
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidAddBookmark:) name:WCSourceTextStorageDidAddBookmarkNotification object:[self textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveBookmark:) name:WCSourceTextStorageDidRemoveBookmarkNotification object:[self textStorage]];
	
	return self;
}

- (NSArray *)lineStartIndexes {
	return [[self textStorage] lineStartIndexes];
}

- (NSSet *)userDefaultsKeyPathsToObserve {
	NSMutableSet *keys = [[[super userDefaultsKeyPathsToObserve] mutableCopy] autorelease];
	
	[keys unionSet:[NSSet setWithObjects:WCEditorShowCodeFoldingRibbonKey, nil]];
	
	return keys;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingFormat:WCEditorShowCodeFoldingRibbonKey]])
		[self setNeedsDisplay:YES];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

static const CGFloat kIconWidthHeight = 11.0;
static const CGFloat kIconPaddingLeft = 1.0;
static const CGFloat kIconPaddingTop = 1.0;
static const CGFloat kCodeFoldingRibbonWidth = 6.0;
- (CGFloat)minimumThickness {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft+kCodeFoldingRibbonWidth;
	return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
	[super drawBackgroundInRect:rect];
	[self drawCodeFoldingRibbonInRect:NSMakeRect(NSMaxX(rect)-kCodeFoldingRibbonWidth, NSMinY(rect), kCodeFoldingRibbonWidth, NSHeight(rect))];
	[super drawCurrentLineHighlightInRect:rect];
	
	for (RSBookmark *bookmark in [[self textStorage] bookmarksForRange:[[self textView] visibleRange]]) {
		NSUInteger numRects;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[bookmark range]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
		
		if (!numRects)
			continue;
		
		NSRect bookmarkRect = rects[0];
		bookmarkRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:bookmarkRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(bookmarkRect));
		bookmarkRect = NSInsetRect(bookmarkRect, 1.0, 0.0);
		
		NSImage *bookmarkImage = [NSImage imageNamed:@"Bookmark"];
		
		[bookmarkImage drawInRect:NSMakeRect(NSMinX(bookmarkRect)+kIconPaddingLeft, NSMinY(bookmarkRect)+kIconPaddingTop, kIconWidthHeight, kIconWidthHeight) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey]) {
		[super drawLineNumbersInRect:NSMakeRect(NSMinX(rect), NSMinY(rect), NSWidth(rect)-kCodeFoldingRibbonWidth, NSHeight(rect))];
		[super drawRightMarginInRect:NSMakeRect(NSMinX(rect), NSMinY(rect), NSWidth(rect)-kCodeFoldingRibbonWidth, NSHeight(rect))];
	}
	else {
		[super drawLineNumbersInRect:rect];
		[super drawRightMarginInRect:rect];
	}
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
- (void)drawCodeFoldingRibbonInRect:(NSRect)ribbonRect; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])
		return;
	
	[[NSColor colorWithCalibratedWhite:232.0/255.0 alpha:1.0] setFill];
	NSRectFill(ribbonRect);
	
	NSArray *folds = [[[[self delegate] sourceScannerForSourceRulerView:self] folds] foldsForRange:[[self textView] visibleRange]];
	NSColor *topLevelFoldColor = [NSColor colorWithCalibratedWhite:212.0/255.0 alpha:1.0];
	
	for (WCFold *fold in folds) {
		NSRange foldRange = [fold range];
		if (NSMaxRange(foldRange) == [[[self textView] string] length])
			foldRange.length--;
		
		NSUInteger rectCount;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:foldRange] withinSelectedCharacterRange:foldRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
		
		if (!rectCount)
			continue;
		
		NSRect foldRect = rects[0];
		foldRect = NSMakeRect(NSMinX(ribbonRect), [self convertPoint:foldRect.origin fromView:[self clientView]].y, NSWidth(ribbonRect), NSHeight(foldRect));
		
		[topLevelFoldColor setFill];
		NSRectFill(foldRect);
		
		[self _drawFoldsForFold:fold inRect:ribbonRect topLevelFoldColor:topLevelFoldColor];
	}
	
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
			NSRectArray rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(lineStartIndex, 0) withinSelectedCharacterRange:NSNotFoundRange inTextContainer:container rectCount:&rectCount];
			
			if (rectCount) {
				NSUInteger rectIndex;
				for (rectIndex = 0; rectIndex < rectCount; rectIndex++) {
					NSRect convertedRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:rects[rectIndex].origin fromView:[self clientView]].y, NSWidth(rects[rectIndex]), NSHeight(rects[rectIndex]));
					
					if ((point.y >= NSMinY(convertedRect)) && (point.y < NSMaxY(convertedRect)))
						return lineNumber;
				}
			}
		}
		
		if (lineStartIndex > NSMaxRange(range))
			break;
	}
	return NSNotFound;
}

- (void)_drawFoldsForFold:(WCFold *)fold inRect:(NSRect)ribbonRect topLevelFoldColor:(NSColor *)topLevelFoldColor; {
	static const CGFloat stepAmount = 0.15;
	NSColor *colorForThisFoldLevel = [topLevelFoldColor darkenBy:stepAmount*((CGFloat)[fold level]+1)];
	
	for (WCFold *childFold in [fold childNodes]) {
		NSRange foldRange = [childFold range];
		if (NSMaxRange(foldRange) == [[[self textView] string] length])
			foldRange.length--;
		
		NSUInteger rectCount;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:foldRange] withinSelectedCharacterRange:foldRange inTextContainer:[[self textView] textContainer] rectCount:&rectCount];
		
		if (!rectCount)
			continue;
		
		NSRect foldRect = rects[0];
		foldRect = NSMakeRect(NSMinX(ribbonRect), [self convertPoint:foldRect.origin fromView:[self clientView]].y, NSWidth(ribbonRect), NSHeight(foldRect));
		
		[colorForThisFoldLevel setFill];
		NSRectFill(foldRect);
		
		[self _drawFoldsForFold:childFold inRect:ribbonRect topLevelFoldColor:topLevelFoldColor];
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
- (void)_sourceScannerDidFinishScanningFolds:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
@end
