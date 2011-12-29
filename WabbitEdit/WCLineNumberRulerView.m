//
//  WCLineNumberRulerView.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCLineNumberRulerView.h"
#import "RSDefines.h"
#import "NSString+WCExtensions.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"

#define DEFAULT_THICKNESS	20.0
#define RULER_MARGIN		8.0

@interface WCLineNumberRulerView ()
@property (readwrite,assign,nonatomic) BOOL shouldRecalculateLineStartIndexes;
@property (readonly,nonatomic) NSFont *textFont;
@property (readonly,nonatomic) NSColor *textColor;
@property (readonly,nonatomic) NSColor *backgroundColor;
@property (readonly,nonatomic) NSDictionary *selectedTextAttributes;

- (void)_calculateLineStartIndexes;
@end

@implementation WCLineNumberRulerView
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_lineStartIndexes release];
	[super dealloc];
}

- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation {
	if (!(self = [super initWithScrollView:scrollView orientation:NSVerticalRuler]))
		return nil;
	
	_lineStartIndexes = [[NSMutableArray alloc] initWithCapacity:0];
	
	[self setClientView:[scrollView documentView]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[[scrollView documentView] textStorage]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:[scrollView documentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentLineColorDidChange:) name:WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification object:nil];
	
	[self setShouldRecalculateLineStartIndexes:YES];
	
	return self;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResizeObservingToken];
	
	if (newWindow) {
		_windowDidResizeObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
	}
}

- (void)viewWillDraw {
	[super viewWillDraw];
	
	CGFloat oldThickness = [self ruleThickness];
	CGFloat newThickness = [self minimumThickness];
	
	if (fabs(oldThickness - newThickness) > 1)
		[self setRuleThickness:newThickness];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {	
	[[self backgroundColor] set];
	NSRectFill([self bounds]);
	
	NSUInteger numRects;
	NSRectArray rects;
	
	if ([[self textView] selectedRange].length)
		rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[[self textView] selectedRange]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
	else
		rects = [[[self textView] layoutManager] rectArrayForCharacterRange:NSMakeRange([[self textView] selectedRange].location, 0) withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
	
	if (numRects > 0) {
		NSRect lineRect = rects[0];
		lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
		
		if (NSIntersectsRect(lineRect, rect)) {
			
			WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
			
			[[currentTheme currentLineColor] setFill];
			NSRectFill(lineRect);
		}
	}
	
	[self drawLineNumbersInRect:rect];
	
	[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] setStroke];
	[[NSBezierPath bezierPathWithRect:NSMakeRect(NSWidth([self bounds]), 0, 0, NSHeight([self bounds]))] stroke];
	/*
	[[NSColor colorWithCalibratedWhite:0.64 alpha:1.0] setStroke];
	NSBezierPath *dottedLine = [NSBezierPath bezierPathWithRect:NSMakeRect(NSWidth([self bounds]), 0, 0, NSHeight([self bounds]))];
	CGFloat dash[2];
	dash[0] = 1.0;
	dash[1] = 2.0;
	[dottedLine setLineDash:dash count:2 phase:1.0];
	[dottedLine stroke];
	 */
}

- (void)drawBackgroundAndDividerLineInRect:(NSRect)backgroundAndDividerLineRect; {
	NSRect bounds = backgroundAndDividerLineRect;
	
	[[self backgroundColor] setFill];
	NSRectFill(bounds);
	[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] setStroke];
	[[NSBezierPath bezierPathWithRect:NSMakeRect(NSWidth(bounds), 0, 0, NSHeight(bounds))] stroke];
}

- (void)drawLineNumbersInRect:(NSRect)lineNumbersRect; {
	NSRect bounds = lineNumbersRect;
	id view = [self clientView];
	NSLayoutManager *layoutManager = [view layoutManager];
	NSTextContainer	*container = [view textContainer];
	NSRange	glyphRange = [layoutManager glyphRangeForBoundingRect:[[self clientView] visibleRect] inTextContainer:container];
	NSRange range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	NSUInteger lineNumber, lineStartIndex, numberOfLines = [[self lineStartIndexes] count], stringLength = [[view string] length];
	NSUInteger selectedLineNumber = [[[self textView] string] lineNumberForRange:[[self textView] selectedRange]];
	BOOL shouldDrawLineNumbers = YES;
	
	// Fudge the range a tad in case there is an extra new line at end.
	// It doesn't show up in the glyphs so would not be accounted for.
	range.length++;
	
	for (lineNumber = [self lineNumberForCharacterIndex:range.location]; lineNumber < numberOfLines; lineNumber++) {
		lineStartIndex = [[[self lineStartIndexes] objectAtIndex:lineNumber] unsignedIntegerValue];
		//lineStartIndex = (NSUInteger)[[self lineStartIndexes] pointerAtIndex:lineNumber];
		
		if (NSLocationInRange(lineStartIndex, range)) {
			
			// Line numbers are internally stored starting at 0
			if (shouldDrawLineNumbers) {
				NSString *labelText = [NSString stringWithFormat:@"%lu", lineNumber + 1];
				
				NSRect labelRect;
				NSUInteger numRects;
				
				if (lineStartIndex < stringLength)
					labelRect = [layoutManager lineFragmentRectForGlyphAtIndex:[[(NSTextView *)[self clientView] layoutManager] glyphIndexForCharacterAtIndex:lineStartIndex] effectiveRange:NULL];
				else {
					NSRectArray rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(lineStartIndex, 0) withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[view textContainer] rectCount:&numRects];
					if (numRects > 0)
						labelRect = rects[0];
				}
				
				if (lineStartIndex < stringLength || numRects > 0) {
					NSDictionary *textAttributes = [self textAttributesForLineNumber:lineNumber selectedLineNumber:selectedLineNumber];
					
					NSSize stringSize = [labelText sizeWithAttributes:textAttributes];
					
					[labelText drawInRect:NSMakeRect(NSMinX(bounds), [self convertPoint:labelRect.origin fromView:[self clientView]].y + (floor(NSHeight(labelRect)/2.0)-floor(stringSize.height/2.0)), NSWidth(bounds)-floor(RULER_MARGIN/2.0), NSHeight(labelRect)) withAttributes:textAttributes];
				}
			}
		}
		else if (lineStartIndex > NSMaxRange(range))
			break;
	}
}

- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index {
    NSUInteger left = 0, right = [[self lineStartIndexes] count], mid, lineStart;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
        lineStart = [[[self lineStartIndexes] objectAtIndex:mid] unsignedIntegerValue];
        
        if (index < lineStart)
			right = mid;
        else if (index > lineStart)
			left = mid;
        else
			return mid;
    }
    return left;
}

- (NSDictionary *)textAttributesForLineNumber:(NSUInteger)lineNumber selectedLineNumber:(NSUInteger)selectedLineNumber; {
	NSDictionary *textAttributes;
	if (selectedLineNumber == lineNumber ||
		(selectedLineNumber >= [[self lineStartIndexes] count] && lineNumber+1 == selectedLineNumber))
		textAttributes = [self selectedTextAttributes];
	else
		textAttributes = [self textAttributes];
	return textAttributes;
}

@dynamic lineStartIndexes;
- (NSArray *)lineStartIndexes {
	if ([self shouldRecalculateLineStartIndexes]) {
		[self setShouldRecalculateLineStartIndexes:NO];
		
		[self _calculateLineStartIndexes];
	}
	return [[_lineStartIndexes copy] autorelease];
}
@synthesize shouldRecalculateLineStartIndexes=_shouldRecalculateLineStartIndexes;
@dynamic textFont;
- (NSFont *)textFont {
	return [NSFont fontWithName:@"Menlo" size:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
}
@dynamic textColor;
- (NSColor *)textColor {
	return [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
}
@dynamic backgroundColor;
- (NSColor *)backgroundColor {
	return [NSColor colorWithCalibratedWhite:0.929 alpha:1.0];
}
@dynamic textView;
- (NSTextView *)textView {
	return (NSTextView *)[self clientView];
}
@dynamic minimumThickness;
- (CGFloat)minimumThickness {
	NSUInteger			lineCount = [[self lineStartIndexes] count];
    NSMutableString     *sampleString = [NSMutableString string];
    NSUInteger digits = (NSUInteger)log10(lineCount) + 1;
	NSUInteger i;
	
    for (i = 0; i < digits; i++)
        [sampleString appendString:@"8"];
    
    NSSize stringSize = [sampleString sizeWithAttributes:[self textAttributes]];
	
    CGFloat newThickness = ceil(MAX(DEFAULT_THICKNESS, stringSize.width + RULER_MARGIN));
	
	return newThickness;
}
@dynamic textAttributes;
- (NSDictionary *)textAttributes {
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setAlignment:NSRightTextAlignment];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self textFont], NSFontAttributeName, 
            [self textColor], NSForegroundColorAttributeName,
			style,NSParagraphStyleAttributeName,
            nil];
}

@dynamic selectedTextAttributes;
- (NSDictionary *)selectedTextAttributes {
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setAlignment:NSRightTextAlignment];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self textFont], NSFontAttributeName, 
            [NSColor textColor], NSForegroundColorAttributeName,
			style,NSParagraphStyleAttributeName,
            nil];
}

- (void)_calculateLineStartIndexes; {
	NSUInteger characterIndex = 0, stringLength = [[[self textView] string] length], lineEnd, contentEnd;
	
	[_lineStartIndexes removeAllObjects];
	
	do {
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
		
		characterIndex = NSMaxRange([[[self textView] string] lineRangeForRange:NSMakeRange(characterIndex, 0)]);
		
	} while (characterIndex < stringLength);
	
	// Check if text ends with a new line.
	[[[self textView] string] getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineStartIndexes lastObject] unsignedIntegerValue], 0)];
	if (contentEnd < lineEnd)
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	[self setShouldRecalculateLineStartIndexes:YES];
    [self setNeedsDisplay:YES];
}
- (void)_textViewDidChangeSelection:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_currentThemeDidChange:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_currentLineColorDidChange:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
@end
