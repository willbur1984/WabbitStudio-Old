//
//  WCLineNumberRulerView.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCLineNumberRulerView.h"
#import "RSDefines.h"
#import "NSString+RSExtensions.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "WCEditorViewController.h"
#import "NSObject+WCExtensions.h"
#import "NSArray+WCExtensions.h"
#import "NSParagraphStyle+RSExtensions.h"

#define DEFAULT_THICKNESS	20.0
#define RULER_MARGIN		8.0

@interface WCLineNumberRulerView ()
@property (readwrite,assign,nonatomic) BOOL shouldRecalculateLineStartIndexes;
@property (readonly,nonatomic) NSFont *textFont;
@property (readonly,nonatomic) NSFont *selectedTextFont;
@property (readonly,nonatomic) NSColor *textColor;
@property (readonly,nonatomic) NSDictionary *selectedTextAttributes;

- (void)_calculateLineStartIndexes;
- (void)_calculateLineStartIndexesStartingAtLineNumber:(NSUInteger)lineNumber;
@end

@implementation WCLineNumberRulerView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanUpUserDefaultsObserving];
	[_lineStartIndexes release];
	[super dealloc];
}

- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation {
	if (!(self = [super initWithScrollView:scrollView orientation:NSVerticalRuler]))
		return nil;
	
	_lineStartIndexes = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0], nil];
	_lineNumberToRecalculateFrom = 0;
	
	[self setupUserDefaultsObserving];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:[scrollView contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[scrollView contentView]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentLineColorDidChange:) name:WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification object:nil];
	
	[self setShouldRecalculateLineStartIndexes:YES];
	
	return self;
}

- (BOOL)isOpaque {
	return YES;
}

- (void)setClientView:(NSView *)client {
	[super setClientView:client];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextViewDidChangeSelectionNotification object:nil];
	
	if ([client isKindOfClass:[NSTextView class]]) {
		NSTextView *textView = (NSTextView *)client;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[textView textStorage]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:textView];
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
	[self drawBackgroundInRect:rect];
	[self drawCurrentLineHighlightInRect:rect];
	[self drawLineNumbersInRect:rect];
	[self drawRightMarginInRect:rect];
}

- (NSSet *)userDefaultsKeyPathsToObserve {
	return [NSSet setWithObjects:WCEditorShowCurrentLineHighlightKey,WCEditorShowLineNumbersKey, nil];
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorShowLineNumbersKey]])
		[self setNeedsDisplay:YES];
	else if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorShowCurrentLineHighlightKey]])
		[self setNeedsDisplay:YES];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
#pragma mark *** Public Methods ***
- (void)drawBackgroundInRect:(NSRect)backgroundRect; {
	[[self backgroundColor] set];
	NSRectFill(backgroundRect);
}
- (void)drawRightMarginInRect:(NSRect)rightMarginRect; {
	/*
	[[NSColor darkGrayColor] setStroke];
	NSBezierPath *dottedLine = [NSBezierPath bezierPathWithRect:NSMakeRect(NSWidth(rightMarginRect), 0, 0, NSHeight(rightMarginRect))];
	CGFloat dash[2];
	dash[0] = 1.0;
	dash[1] = 2.0;
	[dottedLine setLineDash:dash count:2 phase:1.0];
	[dottedLine stroke];
	 */
	[[NSColor colorWithCalibratedWhite:164.0/255.0 alpha:1.0] setFill];
	NSRectFill(NSMakeRect(NSMaxX(rightMarginRect)-1.0, NSMinY(rightMarginRect), 1.0, NSHeight(rightMarginRect)));
}

- (void)drawBackgroundAndDividerLineInRect:(NSRect)backgroundAndDividerLineRect; {
	NSRect bounds = backgroundAndDividerLineRect;
	
	[[self backgroundColor] setFill];
	NSRectFill(bounds);
	[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] setStroke];
	[[NSBezierPath bezierPathWithRect:NSMakeRect(NSWidth(bounds), 0, 0, NSHeight(bounds))] stroke];
}

- (void)drawCurrentLineHighlightInRect:(NSRect)currentLineHighlightRect; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCurrentLineHighlightKey])
		return;
	
	NSUInteger numRects;
	NSRectArray rects;
	if ([[self textView] selectedRange].length)
		rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[[self textView] string] lineRangeForRange:[[self textView] selectedRange]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
	else
		rects = [[[self textView] layoutManager] rectArrayForCharacterRange:[[self textView] selectedRange] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[[self textView] textContainer] rectCount:&numRects];
	
	if (!numRects)
		return;
	
	NSRect lineRect;
	
	if (numRects == 1)
		lineRect = rects[0];
	else {
		lineRect = NSZeroRect;
		NSUInteger rectIndex;
		for (rectIndex=0; rectIndex<numRects; rectIndex++)
			lineRect = NSUnionRect(lineRect, rects[rectIndex]);
	}
	
	lineRect = NSMakeRect(NSMinX([self bounds]), [self convertPoint:lineRect.origin fromView:[self clientView]].y, NSWidth([self bounds]), NSHeight(lineRect));
	
	if (!NSIntersectsRect(lineRect, [self bounds]) || ![self needsToDrawRect:lineRect])
		return;
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[[currentTheme currentLineColor] colorWithAlphaComponent:0.5] setFill];
	NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	[[currentTheme currentLineColor] setFill];
	NSRectFill(NSMakeRect(NSMinX(lineRect), NSMinY(lineRect), NSWidth(lineRect), 1.0));
	NSRectFill(NSMakeRect(NSMinX(lineRect), NSMaxY(lineRect)-1, NSWidth(lineRect), 1.0));
}

- (void)drawLineNumbersInRect:(NSRect)lineNumbersRect; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowLineNumbersKey])
		return;
	
	NSRect bounds = lineNumbersRect;
	id view = [self clientView];
	NSLayoutManager *layoutManager = [view layoutManager];
	NSTextContainer	*container = [view textContainer];
	NSRange	glyphRange = [layoutManager glyphRangeForBoundingRect:[[self clientView] visibleRect] inTextContainer:container];
	NSRange range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	NSUInteger lineNumber, lineStartIndex, numberOfLines = [[self lineStartIndexes] count], stringLength = [[view string] length];
	NSIndexSet *lineNumbers = [[[self textView] string] lineNumbersForRange:[[self textView] selectedRange]];
	CGFloat lastLinePositionY = -1.0;
	
	// Fudge the range a tad in case there is an extra new line at end.
	// It doesn't show up in the glyphs so would not be accounted for.
	range.length++;
	
	for (lineNumber = [[self lineStartIndexes] lineNumberForRange:range]; lineNumber < numberOfLines; lineNumber++) {
		lineStartIndex = [[[self lineStartIndexes] objectAtIndex:lineNumber] unsignedIntegerValue];
		
		if (NSLocationInRange(lineStartIndex, range)) {
			NSString *labelText = [NSString stringWithFormat:@"%lu", lineNumber + 1];
			
			NSRect labelRect = NSZeroRect;
			NSUInteger numRects = 0;
			
			if (lineStartIndex < stringLength)
				labelRect = [layoutManager lineFragmentRectForGlyphAtIndex:[[(NSTextView *)[self clientView] layoutManager] glyphIndexForCharacterAtIndex:lineStartIndex] effectiveRange:NULL];
			else {
				NSRectArray rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(lineStartIndex, 0) withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[view textContainer] rectCount:&numRects];
				if (numRects)
					labelRect = rects[0];
			}
			
			if (lineStartIndex < stringLength || numRects) {
				if (NSMinY(labelRect) != lastLinePositionY) {
					NSDictionary *textAttributes = [self textAttributesForLineNumber:lineNumber selectedLineNumbers:lineNumbers];
					
					NSSize stringSize = [labelText sizeWithAttributes:textAttributes];
					
					[labelText drawInRect:NSMakeRect(NSMinX(bounds), [self convertPoint:labelRect.origin fromView:[self clientView]].y + (floor(NSHeight(labelRect)/2.0)-floor(stringSize.height/2.0)), NSWidth(bounds)-floor(RULER_MARGIN/2.0), NSHeight(labelRect)) withAttributes:textAttributes];
				}
			}
			
			lastLinePositionY = NSMinY(labelRect);
		}
		
		if (lineStartIndex > NSMaxRange(range))
			break;
	}
}

- (NSDictionary *)textAttributesForLineNumber:(NSUInteger)lineNumber selectedLineNumbers:(NSIndexSet *)selectedLineNumbers; {
	NSDictionary *textAttributes;
	if ([selectedLineNumbers containsIndex:lineNumber])
		textAttributes = [self selectedTextAttributes];
	else
		textAttributes = [self textAttributes];
	return textAttributes;
}
#pragma mark Properties
@dynamic lineStartIndexes;
- (NSArray *)lineStartIndexes {
	if ([self shouldRecalculateLineStartIndexes]) {
		[self setShouldRecalculateLineStartIndexes:NO];
		
		[self _calculateLineStartIndexesStartingAtLineNumber:_lineNumberToRecalculateFrom];
	}
	return [[_lineStartIndexes copy] autorelease];
}
@synthesize shouldRecalculateLineStartIndexes=_shouldRecalculateLineStartIndexes;
@dynamic textFont;
- (NSFont *)textFont {
	return [NSFont fontWithName:@"Menlo" size:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
}
@dynamic selectedTextFont;
- (NSFont *)selectedTextFont {
	return [NSFont fontWithName:@"Menlo-Bold" size:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
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
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowLineNumbersKey])
		return RULER_MARGIN;
	
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
    return [NSDictionary dictionaryWithObjectsAndKeys:[self textFont],NSFontAttributeName,[self textColor],NSForegroundColorAttributeName,[NSParagraphStyle rightAlignedParagraphStyle],NSParagraphStyleAttributeName,nil];
}

@dynamic selectedTextAttributes;
- (NSDictionary *)selectedTextAttributes {
    return [NSDictionary dictionaryWithObjectsAndKeys:[self textFont],NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName,[NSParagraphStyle rightAlignedParagraphStyle],NSParagraphStyleAttributeName,nil];
}
#pragma mark *** Private Methods ***
- (void)_calculateLineStartIndexes; {
	[self _calculateLineStartIndexesStartingAtLineNumber:0];
}

- (void)_calculateLineStartIndexesStartingAtLineNumber:(NSUInteger)lineNumber; {
	NSUInteger characterIndex = [[_lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue], stringLength = [[[self textView] string] length], lineEnd, contentEnd;
	
	[_lineStartIndexes removeObjectsInRange:NSMakeRange(lineNumber, [_lineStartIndexes count]-lineNumber)];
	
	do {
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
		
		characterIndex = NSMaxRange([[[self textView] string] lineRangeForRange:NSMakeRange(characterIndex, 0)]);
		
	} while (characterIndex < stringLength);
	
	[[[self textView] string] getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineStartIndexes lastObject] unsignedIntegerValue], 0)];
	if (contentEnd < lineEnd)
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
}
#pragma mark Notifications
- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	if (([[note object] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	
	NSUInteger lineNumber = [[self lineStartIndexes] lineNumberForRange:[[note object] editedRange]];
	
	_lineNumberToRecalculateFrom = lineNumber;
	
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
- (void)_viewFrameDidChange:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
- (void)_viewBoundsDidChange:(NSNotification *)note {
	[self setNeedsDisplay:YES];
}
@end
