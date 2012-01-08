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
#import "NSObject+WCExtensions.h"
#import "WCEditorViewController.h"
#import "WCSourceToken.h"
#import "RSToolTipManager.h"
#import "WCSourceSymbol.h"
#import "RSFindBarViewController.h"
#import "RSBezelWidgetManager.h"
#import "WCSourceHighlighter.h"
#import "WCKeyboardViewController.h"
#import "WCJumpInWindowController.h"
#import "WCJumpToLineWindowController.h"
#import "NSString+WCExtensions.h"

@interface WCSourceTextView ()

- (void)_commonInit;
- (void)_drawCurrentLineHighlightInRect:(NSRect)rect;
- (void)_drawPageGuideInRect:(NSRect)rect;
- (void)_highlightMatchingBrace;
- (void)_highlightMatchingTempLabel;
- (void)_insertMatchingBraceWithString:(id)string;
- (void)_handleAutoCompletionWithString:(id)string;
@end

@implementation WCSourceTextView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanUpUserDefaultsObserving];
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

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[RSToolTipManager sharedManager] removeView:self];
	
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidBecomeKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResignKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResizeObservingToken];
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	
	if ([self window]) {
		[[RSToolTipManager sharedManager] addView:self];
		
		_windowDidBecomeKeyObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:[self window] queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplayInRect:[self visibleRect] avoidAdditionalLayout:YES];
		}];
		_windowDidResignKeyObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:[self window] queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplayInRect:[self visibleRect] avoidAdditionalLayout:YES];
		}];
		_windowDidResizeObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification object:[self window] queue:nil usingBlock:^(NSNotification *note) {
			[[[self delegate] sourceHighlighterForSourceTextView:self] performHighlightingInVisibleRange];
		}];
	}
}

- (void)drawViewBackgroundInRect:(NSRect)rect {
	[super drawViewBackgroundInRect:rect];
	
	[self _drawPageGuideInRect:rect];
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

- (NSRange)selectionRangeForProposedRange:(NSRange)proposedCharRange granularity:(NSSelectionGranularity)granularity {
	if (granularity != NSSelectByWord)
		return proposedCharRange;
	
	// look for a symbol inside the proposed range
	NSRange symbolRange = [[self string] symbolRangeForRange:proposedCharRange];
	if (symbolRange.location == NSNotFound)
		return proposedCharRange;
	return symbolRange;
}

+ (NSMenu *)defaultMenu; {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Cut", @"Cut") action:@selector(cut:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Copy", @"Copy") action:@selector(copy:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Paste", @"Paste") action:@selector(paste:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Jump to Definition", @"Jump to Definition") action:@selector(jumpToDefinition:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Shift Left", @"Shift Left") action:@selector(shiftLeft:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Shift Right", @"Shift Right") action:@selector(shiftRight:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Comment/Uncomment Selection", @"Comment/Uncomment Selection") action:@selector(commentUncommentSelection:) keyEquivalent:@""];
		
	});
	return retval;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSMenu *retval = [super menuForEvent:event];
	if (retval)
		retval = [[self class] defaultMenu];
	return retval;
}
#pragma mark IBActions
- (IBAction)complete:(id)sender {
	[[WCCompletionWindowController sharedWindowController] showCompletionWindowControllerForSourceTextView:self];
}

- (IBAction)insertTab:(id)sender {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCKeyboardUseTabToNavigateArgumentPlaceholdersKey]) {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:WCEditorIndentUsingKey] unsignedIntegerValue] == WCEditorIndentUsingTabs)
			[super insertTab:nil];
		else {
			NSUInteger tabWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:WCEditorTabWidthKey] unsignedIntegerValue];
			NSMutableString *spacesString = [NSMutableString stringWithCapacity:tabWidth];
			NSUInteger charIndex;
			
			for (charIndex=0; charIndex<tabWidth; charIndex++)
				[spacesString appendString:@" "];
			
			[super insertText:spacesString];
		}
		return;
	}
	
	NSRange placeholderRange = [[self textStorage] nextArgumentPlaceholderRangeForRange:[self selectedRange] inRange:[[self string] lineRangeForRange:[self selectedRange]] wrapAround:YES];
	if (placeholderRange.location == NSNotFound) {
		[super insertTab:sender];
		return;
	}
	
	[self setSelectedRange:placeholderRange];
}

- (IBAction)insertBacktab:(id)sender {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCKeyboardUseTabToNavigateArgumentPlaceholdersKey]) {
		[super insertBacktab:nil];
		return;
	}
	
	NSRange placeholderRange = [[self textStorage] previousArgumentPlaceholderRangeForRange:[self selectedRange] inRange:[[self string] lineRangeForRange:[self selectedRange]] wrapAround:YES];
	if (placeholderRange.location == NSNotFound) {
		[super insertBacktab:sender];
		return;
	}
	
	[self setSelectedRange:placeholderRange];
}

- (IBAction)insertNewline:(id)sender {
	[super insertNewline:nil];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorAutomaticallyIndentAfterNewlinesKey]) {
		NSString *previousLineWhitespaceString;
		NSScanner *previousLineScanner = [[[NSScanner alloc] initWithString:[[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]]] autorelease];
		[previousLineScanner setCharactersToBeSkipped:nil];
		
		if ([previousLineScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&previousLineWhitespaceString])
			[self insertText:previousLineWhitespaceString];
	}
}

- (void)insertText:(id)insertString {
	[super insertText:insertString];
	
	[self _insertMatchingBraceWithString:insertString];
	
	[self _handleAutoCompletionWithString:insertString];
}
#pragma mark NSObject+WCExtensions
- (NSSet *)userDefaultsKeyPathsToObserve {
	return [NSSet setWithObjects:WCEditorShowCurrentLineHighlightKey,WCEditorWrapLinesToEditorWidthKey,WCEditorPageGuideColumnNumberKey,WCEditorShowPageGuideAtColumnKey, nil];
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorShowCurrentLineHighlightKey]] ||
		[keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorPageGuideColumnNumberKey]] ||
		[keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorShowPageGuideAtColumnKey]])
		[self setNeedsDisplayInRect:[self visibleRect] avoidAdditionalLayout:YES];
	else if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingFormat:WCEditorWrapLinesToEditorWidthKey]])
		[self setWrapLines:[[NSUserDefaults standardUserDefaults] boolForKey:WCEditorWrapLinesToEditorWidthKey]];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(jumpInFile:)) {
		WCSourceScanner *sourceScanner = [[self delegate] sourceScannerForSourceTextView:self];
		
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Jump in \"%@\"", @"jump in file menu item title format string"),[[sourceScanner delegate] fileDisplayNameForSourceScanner:sourceScanner]]];
	}
	return YES;
}

#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
	return [super validateUserInterfaceItem:anItem];
}
#pragma mark RSToolTipView
- (NSArray *)toolTipManager:(RSToolTipManager *)toolTipManager toolTipProvidersForToolTipAtPoint:(NSPoint)toolTipPoint {
	NSUInteger charIndex = [self characterIndexForInsertionAtPoint:toolTipPoint];
	if (charIndex >= [[self string] length])
		return nil;
	else if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[[self string] characterAtIndex:charIndex]])
		return nil;
	
	NSRange toolTipRange = [[self string] symbolRangeForRange:NSMakeRange(charIndex, 0)];
	if (toolTipRange.location == NSNotFound)
		return nil;
	
	NSArray *symbols = [[self delegate] sourceTextView:self sourceSymbolsForSymbolName:[[self string] substringWithRange:toolTipRange]];
	if (![symbols count])
		return nil;
	return symbols;
}
#pragma mark WCJumpInDataSource
- (NSArray *)jumpInItems {
	return [[self delegate] sourceSymbolsForSourceTextView:self];
}
- (NSTextView *)jumpInTextView {
	return self;
}
- (NSString *)jumpInFileName {
	WCSourceScanner *sourceScanner = [[self delegate] sourceScannerForSourceTextView:self];
	
	return [[sourceScanner delegate] fileDisplayNameForSourceScanner:sourceScanner];
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
- (IBAction)jumpToLine:(id)sender; {
	[[WCJumpToLineWindowController sharedWindowController] showJumpToLineWindowForTextView:self];
}
- (IBAction)jumpToSelection:(id)sender; {
	[self scrollRangeToVisible:[self selectedRange]];
}
- (IBAction)jumpToDefinition:(id)sender; {
	NSRange symbolRange = [[self string] symbolRangeForRange:[self selectedRange]];
	if (symbolRange.location == NSNotFound) {
		NSBeep();
		
		[[RSBezelWidgetManager sharedWindowController] showString:NSLocalizedString(@"Symbol Not Found, click another one plox", @"Symbol Not Found, click another one plox") centeredInView:[self enclosingScrollView]];
		
		return;
	}
	
	NSArray *symbols = [[self delegate] sourceTextView:self sourceSymbolsForSymbolName:[[self string] substringWithRange:symbolRange]];
	if (![symbols count]) {
		NSBeep();
		
		[[RSBezelWidgetManager sharedWindowController] showString:NSLocalizedString(@"Symbol Not Found, click another one plox", @"Symbol Not Found, click another one plox") centeredInView:[self enclosingScrollView]];
		return;
	}
	else if ([symbols count] == 1) {
		WCSourceSymbol *symbol = [symbols lastObject];
		
		[self setSelectedRange:[symbol range]];
		[self scrollRangeToVisible:[self selectedRange]];
	}
	else {
		NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
		[menu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
		
		for (WCSourceSymbol *symbol in symbols) {
			NSString *fileDisplayName = [[[symbol sourceScanner] delegate] fileDisplayNameForSourceScanner:[symbol sourceScanner]];
			NSMenuItem *item = [menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (%@:%lu)", @"jump to definition contextual menu format string"),[symbol name],fileDisplayName,[symbol lineNumber]+1] action:@selector(_symbolMenuClicked:) keyEquivalent:@""];
			
			[item setImage:[symbol icon]];
			[item setTarget:self];
			[item setRepresentedObject:symbol];
		}
		
		NSUInteger glyphIndex = [[self layoutManager] glyphIndexForCharacterAtIndex:symbolRange.location];
		NSRect lineRect = [[self layoutManager] lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
		NSPoint selectedPoint = [[self layoutManager] locationForGlyphAtIndex:glyphIndex];
		
		lineRect.origin.y += lineRect.size.height;
		lineRect.origin.x += selectedPoint.x;
		
		NSCursor *currentCursor = [[self enclosingScrollView] documentCursor];
		
		if (![menu popUpMenuPositioningItem:nil atLocation:lineRect.origin inView:self])
			[currentCursor push];
	}
}
- (IBAction)jumpInFile:(id)sender; {
	[[WCJumpInWindowController sharedWindowController] showJumpInWindowWithDataSource:self];
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
@dynamic wrapLines;
- (BOOL)wrapLines {
	return (![[self enclosingScrollView] hasHorizontalScroller]);
}
- (void)setWrapLines:(BOOL)wrapLines {
	if ([self wrapLines] == wrapLines)
		return;
	
	NSScrollView *textScrollView = [self enclosingScrollView];
	NSSize contentSize = [textScrollView contentSize];
	[self setMinSize:contentSize];
	NSTextContainer *textContainer = [self textContainer];
	
	if (wrapLines) {
		[textScrollView setHasHorizontalScroller:NO];
		[textContainer setContainerSize:NSMakeSize(contentSize.width, CGFLOAT_MAX)];
		[textContainer setWidthTracksTextView: YES];
		[self setHorizontallyResizable: NO];
	}
	else {
		[textScrollView setHasHorizontalScroller:YES];
		[textContainer setContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
		[textContainer setWidthTracksTextView: NO];
		[self setHorizontallyResizable: YES];
	}
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self setSelectedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme selectionColor],NSBackgroundColorAttributeName, nil]];
	[self setBackgroundColor:[currentTheme backgroundColor]];
	[self setInsertionPointColor:[currentTheme cursorColor]];
	
	[self setupUserDefaultsObserving];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectionColorDidChange:) name:WCFontAndColorThemeManagerSelectionColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundColorDidChange:) name:WCFontAndColorThemeManagerBackgroundColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentLineColorDidChange:) name:WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cursorColorDidChange:) name:WCFontAndColorThemeManagerCursorColorDidChangeNotification object:nil];
}

- (void)_drawCurrentLineHighlightInRect:(NSRect)rect; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCurrentLineHighlightKey])
		return;
	
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
	[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(lineRect, 1.0, 0) xRadius:5.0 yRadius:5.0] fill];
}

- (void)_drawPageGuideInRect:(NSRect)rect; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowPageGuideAtColumnKey])
		return;
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil];
	CGFloat width = [@" " sizeWithAttributes:attributes].width;
	NSUInteger columnNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:WCEditorPageGuideColumnNumberKey] unsignedIntegerValue];
	CGFloat xPosition = floor(width*columnNumber);
	NSRect guideRect = NSMakeRect(xPosition, NSMinY([self bounds]), 1.0, NSHeight([self bounds]));
	
	if (!NSIntersectsRect(guideRect, rect) ||
		![self needsToDrawRect:guideRect])
		return;
	
	guideRect.size.width = NSWidth([self bounds]) - xPosition;
	
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.35] setFill];
	NSRectFillUsingOperation(guideRect, NSCompositeSourceOver);
	
	
	guideRect.size.width = 1.0;
	
	[[NSColor lightGrayColor] setFill];
	NSRectFill(guideRect);
}

- (void)_highlightMatchingBrace; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowMatchingBraceHighlightKey])
		return;
	// need at least two characters in our string to be able to match
	else if ([[self string] length] <= 1)
		return;
	// return early if we have any text selected
	else if ([self selectedRange].length)
		return;
	
	static NSCharacterSet *closingCharacterSet = nil;
	static NSCharacterSet *openingCharacterSet = nil;
	if (!closingCharacterSet) {
		closingCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@")]}"] retain];
		openingCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"([{"] retain];
	}
	// return early if the character at the caret position is not one our closing brace characters
	if (![closingCharacterSet characterIsMember:[[self string] characterAtIndex:[self selectedRange].location-1]])
		return;
	
	unichar closingBraceCharacter = [[self string] characterAtIndex:[self selectedRange].location-1];
	NSUInteger numberOfClosingBraces = 0, numberOfOpeningBraces = 0;
	NSInteger characterIndex;
	
	// scan backwards starting at the selected character index
	for (characterIndex = [self selectedRange].location-1; characterIndex > 0; characterIndex--) {
		unichar charAtIndex = [[self string] characterAtIndex:characterIndex];
		
		// increment the number of opening braces
		if ([openingCharacterSet characterIsMember:charAtIndex]) {
			numberOfOpeningBraces++;
			
			// if the number of opening and closing braces are equal and the opening and closing characters match
			// show the find indicator on the opening brace
			if (numberOfOpeningBraces == numberOfClosingBraces &&
				((closingBraceCharacter == ')' && charAtIndex == '(') ||
				 (closingBraceCharacter == ']' && charAtIndex == '[') ||
				 (closingBraceCharacter == '}' && charAtIndex == '{'))) {
					[self showFindIndicatorForRange:NSMakeRange(characterIndex, 1)];
					return;
				}
			// otherwise the braces don't match, beep at the user because we are angry
			else if (numberOfOpeningBraces > numberOfClosingBraces) {
				NSBeep();
				return;
			}
		}
		// increment the number of closing braces
		else if ([closingCharacterSet characterIsMember:charAtIndex])
			numberOfClosingBraces++;
	}
	
	NSBeep();
}

- (void)_highlightMatchingTempLabel; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowMatchingTemporaryLabelHighlightKey])
		return;
	// need at least two characters in order to match
	else if ([[self string] length] <= 2)
		return;
	// selection cannot have a length
	else if ([self selectedRange].length)
		return;
	
	NSRange selectedRange = [self selectedRange];
	if ([[self string] characterAtIndex:selectedRange.location-1] != '_')
		return;
	// dont highlight the temp labels themselves
	else if ([[self string] lineRangeForRange:selectedRange].location == selectedRange.location-1)
		return;
	
	// number of references (going forwards or backwards) we are looking for
	__block NSInteger numberOfReferences = 0;
	
	NSUInteger stringLength = [[self string] length];
	NSInteger charIndex;
	
	// count of the number of references so we know how many temp labels to skip over
	for (charIndex = selectedRange.location-2; charIndex > 0; charIndex--) {
		unichar charAtIndex = [[self string] characterAtIndex:charIndex];
		
		// '+' means search forward in the file
		if (charAtIndex == '+')
			numberOfReferences++;
		// '-' means seach backwards in the file
		else if (charAtIndex == '-')
			numberOfReferences--;
		// otherwise we are done counting references
		else
			break;
	}
	
	// if we didn't count any references, it's an underscore by itself
	if (!numberOfReferences) {
		static NSCharacterSet *delimiterCharSet;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			NSMutableCharacterSet *charSet = [[[NSCharacterSet whitespaceCharacterSet] mutableCopy] autorelease];
			[charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
			delimiterCharSet = [charSet copy];
		});
		
		// we need to make sure it isn't part of another word before continuing the search
		if (![delimiterCharSet characterIsMember:[[self string] characterAtIndex:selectedRange.location-2]])
			return;
		
		// otherwise count it as a single forward reference
		numberOfReferences++;
	}
	
	// always enumerate by lines, adding the reverse flag when we have a negative number of references
	__block BOOL foundMatchingTempLabel = NO;
	NSStringEnumerationOptions enumOptions = NSStringEnumerationByLines;
	if (numberOfReferences < 0)
		enumOptions |= NSStringEnumerationReverse;
	// we want to search either from our selected index forward to the end of the file
	// or backwards from our selected index to the beginning of the file
	NSRange enumRange = (numberOfReferences > 0)?NSMakeRange(selectedRange.location, stringLength-selectedRange.location):NSMakeRange(0, selectedRange.location);
	
	[[self string] enumerateSubstringsInRange:enumRange options:enumOptions usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		// the first character has to be an underscore
		if (substringRange.length && [substring characterAtIndex:0] == '_') {
			// make sure the underscore isn't part of another symbol (i.e. a label)
			NSRange symbolRange = [[self string] symbolRangeForRange:NSMakeRange(substringRange.location, 0)];
			if (symbolRange.length != 1)
				return;
			
			// make sure the underscore isn't part of a block comment
			WCSourceToken *token = [[[[self delegate] sourceScannerForSourceTextView:self] tokens] sourceTokenForRange:substringRange];
			if (NSLocationInRange(substringRange.location, [token range]) &&
				[token type] == WCSourceTokenTypeComment)
				return;
			
			// decrement the number of references, checking for 0
			if (numberOfReferences > 0 && (!(--numberOfReferences))) {
				foundMatchingTempLabel = YES;
				*stop = YES;
				
				[self showFindIndicatorForRange:NSMakeRange(substringRange.location, 1)];
			}
			// increment the number of references, checking for 0
			else if (numberOfReferences < 0 && (!(++numberOfReferences))) {
				foundMatchingTempLabel = YES;
				*stop = YES;
				
				[self showFindIndicatorForRange:NSMakeRange(substringRange.location, 1)];
			}
		}
	}];
	
	// if we didn't find a matching temp label, beep at the user because we are angry
	if (!foundMatchingTempLabel)
		NSBeep();
}

- (void)_insertMatchingBraceWithString:(id)string; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorAutomaticallyInsertMatchingBraceKey])
		return;
	// "string" can only be an opening brace character if it's 1 character long
	else if ([string length] != 1)
		return;
	
	static NSCharacterSet *openBraceCharacters;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		openBraceCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"{(["] retain];
	});
	
	// if the only character isn't part of the brace characters we recognize, return early
	if (![openBraceCharacters characterIsMember:[string characterAtIndex:0]])
		return;
	
	// insert the appropriate matching brace character
	switch ([string characterAtIndex:0]) {
		case '(':
			[super insertText:@")"];
			break;
		case '[':
			[super insertText:@"]"];
			break;
		case '{':
			[super insertText:@"}"];
			break;
		default:
			break;
	}
	
	// adjust the selected range since we inserted an additional character
	[self setSelectedRange:NSMakeRange([self selectedRange].location-1, 0)];
}

- (void)_handleAutoCompletionWithString:(id)string; {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorSuggestCompletionsWhileTypingKey])
		return;
	// only trigger auto completion when the user types a single character
	// disregard single character inserts if they are part of an undo or redo
	else if ([string length] != 1 ||
			 [[self undoManager] isUndoing] ||
			 [[self undoManager] isRedoing]) {
		[_completionTimer invalidate];
		_completionTimer = nil;
		return;
	}
	
	// only trigger on certain characters, for now this is letters, numbers and a few additional symbol characters
	static NSCharacterSet *legalChars;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableCharacterSet *charSet = [[[NSCharacterSet letterCharacterSet] mutableCopy] autorelease];
		[charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
		[charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_!?.#"]];
		legalChars = [charSet copy];
	});
	
	// if our single character isn't part of our legal character set, return early
	if (![legalChars characterIsMember:[string characterAtIndex:0]]) {
		[_completionTimer invalidate];
		_completionTimer = nil;
		return;
	}
	
	NSRange completionRange = [self rangeForUserCompletion];
	NSRange lineRange = [[self string] lineRangeForRange:completionRange];
	
	// special case, don't complete when typing at the beginning of a line, the user is usually typing a new label in this case, no need to put the completion up and annoy them
	// the exception being if the first character typed was a '#' or '.' which are preprocessor and directive keywords respectively
	if (completionRange.location == lineRange.location) {
		unichar lineChar = [[self string] characterAtIndex:lineRange.location];
		if (lineChar != '.' && lineChar != '#') {
			[_completionTimer invalidate];
			_completionTimer = nil;
			return;
		}
	}
	
	CGFloat completionDelay = [[NSUserDefaults standardUserDefaults] floatForKey:WCEditorSuggestCompletionsWhileTypingDelayKey];
	
	// if the timer already exists, restart it
	if (_completionTimer)
		[_completionTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:completionDelay]];
	// otherwise create the timer
	else {
		_completionTimer = [NSTimer scheduledTimerWithTimeInterval:completionDelay target:self selector:@selector(_completionTimerCallback:) userInfo:nil repeats:NO];
	}
}
#pragma mark IBActions
- (IBAction)_symbolMenuClicked:(id)sender {
	[self setSelectedRange:[sender range]];
	[self scrollRangeToVisible:[self selectedRange]];
}

#pragma mark Notifications
- (void)_textViewDidChangeSelection:(NSNotification *)note {
	NSRange oldSelectedRange = [[[note userInfo] objectForKey:@"NSOldSelectedCharacterRange"] rangeValue];
	// we only want to match braces and temp labels if there was no previous selection, the new selected index is greater than the previous one, and the difference between them is 1 (meaning the user only moved the caret a single position)
	if (!oldSelectedRange.length &&
		oldSelectedRange.location < [self selectedRange].location &&
		[self selectedRange].location - oldSelectedRange.location == 1) {
		
		[self _highlightMatchingBrace];
		[self _highlightMatchingTempLabel];
	}
	
	[self setNeedsDisplayInRect:[self visibleRect] avoidAdditionalLayout:YES];
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
#pragma mark Callbacks
- (void)_completionTimerCallback:(NSTimer *)timer {
	[_completionTimer invalidate];
	_completionTimer = nil;
	
	[self complete:nil];
}
@end
