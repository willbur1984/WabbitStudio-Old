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

@interface WCSourceRulerView ()
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@property (readwrite,assign,nonatomic) NSUInteger clickedLineNumber;

- (NSUInteger)_lineNumberForPoint:(NSPoint)point;
@end

@implementation WCSourceRulerView
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

static const CGFloat kIconWidthHeight = 11.0;
static const CGFloat kIconPaddingLeft = 1.0;
static const CGFloat kIconPaddingTop = 1.0;
- (CGFloat)minimumThickness {
	return [super minimumThickness]+kIconWidthHeight+kIconPaddingLeft;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
	[super drawBackgroundInRect:rect];
	[super drawCurrentLineHighlightInRect:rect];
	
	for (RSBookmark *bookmark in [[self textStorage] bookmarksForRange:[[self textView] visibleRange]]) {
		NSUInteger numRects;
		NSRectArray rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[bookmark range]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
		
		if (!numRects)
			continue;
		
		NSRect breakpointRect = rects[0];
		breakpointRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:breakpointRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(breakpointRect));
		breakpointRect = NSInsetRect(breakpointRect, 1.0, 0.0);
		
		NSImage *breakpointImage = [NSImage imageNamed:@"Bookmark"];
		
		[breakpointImage drawInRect:NSMakeRect(NSMinX(breakpointRect)+kIconPaddingLeft, NSMinY(breakpointRect)+kIconPaddingTop, kIconWidthHeight, kIconWidthHeight) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
	
	[super drawLineNumbersInRect:rect];
	[super drawRightMarginInRect:rect];
}

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

@dynamic textStorage;
- (WCSourceTextStorage *)textStorage {
	return (WCSourceTextStorage *)[[self textView] textStorage];
}

@synthesize clickedLineNumber=_clickedLineNumber;

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

- (IBAction)_toggleBookmark:(id)sender; {
	RSBookmark *bookmark = [[self textStorage] bookmarkAtLineNumber:[self clickedLineNumber]];
	
	if (bookmark)
		[[self textStorage] removeBookmark:bookmark];
	else {
		bookmark = [RSBookmark bookmarkWithRange:NSMakeRange([[[self textView] string] rangeForLineNumber:[self clickedLineNumber]].location, 0) visibleRange:NSEmptyRange textStorage:[self textStorage]];
		[[self textStorage] addBookmark:bookmark];
	}
}

- (void)_textStorageDidAddBookmark:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_textStorageDidRemoveBookmark:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
@end
