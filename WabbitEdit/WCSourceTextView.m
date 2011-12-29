//
//  WCSourceTextView.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceTextView.h"
#import "WCSourceToken.h"
#import "WCSourceScanner.h"
#import "NSArray+WCExtensions.h"
#import "RSDefines.h"
#import "WCCompletionWindowController.h"
#import "WCFontAndColorThemeManager.h"
#import "WCFontAndColorTheme.h"
#import "NSAttributedString+WCExtensions.h"

@interface WCSourceTextView ()

- (void)_commonInit;
- (void)_updateCurrentLineHighlight;
- (void)_drawCurrentLineHighlightInRect:(NSRect)rect;
@end

@implementation WCSourceTextView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container {
	if (!(self = [super initWithFrame:frameRect textContainer:container]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)drawViewBackgroundInRect:(NSRect)rect {
	[super drawViewBackgroundInRect:rect];
	
	[self _drawCurrentLineHighlightInRect:rect];
}

- (NSRange)rangeForUserCompletion {
	static NSRegularExpression *regex;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		regex = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z0-9_!?.#]+" options:0 error:NULL];
	});
	
	NSRange selectedRange = [self selectedRange];
	__block NSRange completionRange = NSNotFoundRange;
	NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
	
	[regex enumerateMatchesInString:[self string] options:0 range:lineRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInOrEqualToRange(selectedRange.location, [result range])) {
			completionRange = [result range];
			*stop = YES;
		}
	}];
	
	return completionRange;
}
#pragma mark IBActions
- (IBAction)complete:(id)sender {
	[[WCCompletionWindowController sharedWindowController] showCompletionWindowControllerForSourceTextView:self];
}

- (IBAction)insertTab:(id)sender {
	NSRange placeholderRange = [[self textStorage] nextArgumentPlaceholderRangeForRange:[self selectedRange] inRange:[[self string] lineRangeForRange:[self selectedRange]] wrapAround:YES];
	if (placeholderRange.location == NSNotFound) {
		[super insertTab:sender];
		return;
	}
	
	[self setSelectedRange:placeholderRange];
}

- (IBAction)insertBacktab:(id)sender {
	NSRange placeholderRange = [[self textStorage] previousArgumentPlaceholderRangeForRange:[self selectedRange] inRange:[[self string] lineRangeForRange:[self selectedRange]] wrapAround:YES];
	if (placeholderRange.location == NSNotFound) {
		[super insertBacktab:sender];
		return;
	}
	
	[self setSelectedRange:placeholderRange];
}
#pragma mark *** Public Methods ***
#pragma mark IBActions
- (IBAction)jumpToNextPlaceholder:(id)sender; {
	NSRange placeholderRange = [[self textStorage] nextArgumentPlaceholderRangeForRange:[self selectedRange] inRange:NSMakeRange(0, [[self string] length]) wrapAround:YES];
	if (placeholderRange.location == NSNotFound) {
		NSBeep();
		return;
	}
	
	[self setSelectedRange:placeholderRange];
}
- (IBAction)jumpToPreviousPlaceholder:(id)sender; {
	NSRange placeholderRange = [[self textStorage] previousArgumentPlaceholderRangeForRange:[self selectedRange] inRange:NSMakeRange(0, [[self string] length]) wrapAround:YES];
	if (placeholderRange.location == NSNotFound) {
		NSBeep();
		return;
	}
	
	[self setSelectedRange:placeholderRange];
}

- (IBAction)shiftLeft:(id)sender; {
	if ([self selectedRange].length) {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		
		[[lineString string] enumerateSubstringsInRange:NSMakeRange(0, [lineString length]) options:NSStringEnumerationByLines|NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			NSRange wordRange = [substring rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
			
			if (wordRange.location == NSNotFound)
				return;
			else if ([substring rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:0 range:NSMakeRange(0, [substring length]-wordRange.location)].location == NSNotFound)
				return;
			
			[lineString deleteCharactersInRange:NSMakeRange(substringRange.location, 1)];
		}];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			[self setSelectedRange:oldRange];
		}
	}
	else {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSRange wordRange = [[lineString string] rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
		
		if (wordRange.location == NSNotFound) {
			NSBeep();
			return;
		}
		else if ([[lineString string] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:0 range:NSMakeRange(0, [lineString length]-wordRange.location)].location == NSNotFound) {
			NSBeep();
			return;
		}
		
		[lineString deleteCharactersInRange:NSMakeRange(0, 1)];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			oldRange.location--;
			[self setSelectedRange:oldRange];
		}
	}
}
- (IBAction)shiftRight:(id)sender; {
	if ([self selectedRange].length) {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[[[WCFontAndColorThemeManager sharedManager] currentTheme] plainTextFont],NSFontAttributeName, nil];
		
		[[lineString string] enumerateSubstringsInRange:NSMakeRange(0, [lineString length]) options:NSStringEnumerationByLines|NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			NSRange wordRange = [substring rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
			
			if (wordRange.location == NSNotFound)
				return;
			else if ([substring rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:0 range:NSMakeRange(0, [substring length]-wordRange.location)].location == NSNotFound)
				return;
			
			[lineString insertAttributedString:[[[NSAttributedString alloc] initWithString:@"\t" attributes:attributes] autorelease] atIndex:substringRange.location];
		}];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			[self setSelectedRange:oldRange];
		}
	}
	else {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSRange wordRange = [[lineString string] rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
		
		if (wordRange.location == NSNotFound) {
			NSBeep();
			return;
		}
		else if ([[lineString string] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:0 range:NSMakeRange(0, [lineString length]-wordRange.location)].location == NSNotFound) {
			NSBeep();
			return;
		}
		
		[lineString insertAttributedString:[[[NSAttributedString alloc] initWithString:@"\t" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[[[WCFontAndColorThemeManager sharedManager] currentTheme] plainTextFont],NSFontAttributeName, nil]] autorelease] atIndex:0];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			oldRange.location++;
			[self setSelectedRange:oldRange];
		}
	}
}

- (IBAction)commentUncommentSelection:(id)sender; {
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^;+" options:NSRegularExpressionAnchorsMatchLines error:NULL];
	if ([regex rangeOfFirstMatchInString:[self string] options:0 range:[[self string] lineRangeForRange:[self selectedRange]]].location == NSNotFound)
		[self commentSelection:nil];
	else
		[self uncommentSelection:nil];
}
- (IBAction)commentSelection:(id)sender; {
	if ([self selectedRange].length) {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSString *commentString = NSLocalizedString(@";;", @"comment string");
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[[[WCFontAndColorThemeManager sharedManager] currentTheme] plainTextFont],NSFontAttributeName, nil];
		__block NSUInteger numberOfComments = 0;
		
		[[lineString string] enumerateSubstringsInRange:NSMakeRange(0, [lineString length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired|NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			[lineString insertAttributedString:[[[NSAttributedString alloc] initWithString:commentString attributes:attributes] autorelease] atIndex:substringRange.location];
			numberOfComments++;
		}];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			oldRange.location += [commentString length];
			oldRange.length += (--numberOfComments)*[commentString length];
			[self setSelectedRange:oldRange];
		}
	}
	else {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSString *commentString = NSLocalizedString(@";;", @"comment string");
		
		[lineString insertAttributedString:[[[NSAttributedString alloc] initWithString:commentString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[[[WCFontAndColorThemeManager sharedManager] currentTheme] plainTextFont],NSFontAttributeName, nil]] autorelease] atIndex:0];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			oldRange.location += [commentString length];
			[self setSelectedRange:oldRange];
		}
	}
}
- (IBAction)uncommentSelection:(id)sender; {
	if ([self selectedRange].length) {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSString *commentString = NSLocalizedString(@";;", @"comment string");
		__block NSUInteger numberOfComments = 0;
		
		[[lineString string] enumerateSubstringsInRange:NSMakeRange(0, [lineString length]) options:NSStringEnumerationByLines|NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			NSRange commentRange = [[lineString string] rangeOfString:commentString options:0 range:substringRange];
			if (commentRange.location == NSNotFound || commentRange.location != substringRange.location)
				return;
			
			[lineString deleteCharactersInRange:NSMakeRange(substringRange.location, [commentString length])];
			numberOfComments++;
		}];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			oldRange.location -= [commentString length];
			oldRange.length -= (--numberOfComments)*[commentString length];
			[self setSelectedRange:oldRange];
		}
	}
	else {
		NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
		NSMutableAttributedString *lineString = [[[[self textStorage] attributedSubstringFromRange:lineRange] mutableCopy] autorelease];
		NSString *commentString = NSLocalizedString(@";;", @"comment string");
		NSRange commentRange = [[lineString string] rangeOfString:commentString];
		
		if (commentRange.location == NSNotFound || commentRange.location != 0) {
			NSBeep();
			return;
		}
		
		[lineString deleteCharactersInRange:NSMakeRange(0, [commentString length])];
		
		NSRange oldRange = [self selectedRange];
		
		if ([self shouldChangeTextInRange:lineRange replacementString:[lineString string]]) {
			[[self textStorage] replaceCharactersInRange:lineRange withAttributedString:lineString];
			[self didChangeText];
			
			oldRange.location -= [commentString length];
			[self setSelectedRange:oldRange];
		}
	}
}
#pragma mark Properties
@dynamic delegate;
- (id<WCSourceTextViewDelegate>)delegate {
	return _delegate;
}
- (void)setDelegate:(id<WCSourceTextViewDelegate>)delegate {
	if (_delegate == delegate)
		return;
	
	_delegate = delegate;
	
	[super setDelegate:delegate];
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self setSelectedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme selectionColor],NSBackgroundColorAttributeName, nil]];
	[self setBackgroundColor:[currentTheme backgroundColor]];
	[self setInsertionPointColor:[currentTheme cursorColor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectionColorDidChange:) name:WCFontAndColorThemeManagerSelectionColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundColorDidChange:) name:WCFontAndColorThemeManagerBackgroundColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentLineColorDidChange:) name:WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cursorColorDidChange:) name:WCFontAndColorThemeManagerCursorColorDidChangeNotification object:nil];
}

- (void)_drawCurrentLineHighlightInRect:(NSRect)rect; {
	NSUInteger numRects;
	NSRectArray rects;
	
	if ([self selectedRange].length)
		rects = [[self layoutManager] rectArrayForCharacterRange:[[self string] lineRangeForRange:[self selectedRange]] withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[self textContainer] rectCount:&numRects];
	else
		rects = [[self layoutManager] rectArrayForCharacterRange:NSMakeRange([self selectedRange].location, 0) withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[self textContainer] rectCount:&numRects];
	
	if (!numRects)
		return;
	
	NSRect lineRect = rects[0];
	lineRect.origin.x = NSMinX([self bounds]);
	lineRect.size.width = NSWidth([self bounds]);
	
	if (!NSIntersectsRect(lineRect, rect))
		return;
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[currentTheme currentLineColor] setFill];
	NSRectFill(lineRect);
}

- (void)_updateCurrentLineHighlight; {
	[self setNeedsDisplayInRect:[self visibleRect] avoidAdditionalLayout:YES];
}
#pragma mark Notifications
- (void)_textViewDidChangeSelection:(NSNotification *)note {
	[self _updateCurrentLineHighlight];
}
- (void)_currentThemeDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self setSelectedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme selectionColor],NSBackgroundColorAttributeName, nil]];
	[self setBackgroundColor:[currentTheme backgroundColor]];
	[self setInsertionPointColor:[currentTheme cursorColor]];
}
- (void)_selectionColorDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self setSelectedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme selectionColor],NSBackgroundColorAttributeName, nil]];
}
- (void)_backgroundColorDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self setBackgroundColor:[currentTheme backgroundColor]];
}
- (void)_currentLineColorDidChange:(NSNotification *)note {
	[self setNeedsDisplayInRect:[self visibleRect] avoidAdditionalLayout:YES];
}
- (void)_cursorColorDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self setInsertionPointColor:[currentTheme cursorColor]];
}
@end
