//
//  RSFindBarViewController.m
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSFindBarViewController.h"
#import "NSPointerArray+WCExtensions.h"
#import "RSFindOptionsViewController.h"
#import "RSDefines.h"

@interface RSFindBarViewController ()
@property (readonly,nonatomic) NSTextView *textView;
@property (readwrite,assign,nonatomic) BOOL wrapAround;
@property (readwrite,copy,nonatomic) NSString *lastFindString;
@property (readonly,nonatomic) RSFindOptionsViewController *findOptionsViewController;
@property (readwrite,retain,nonatomic) NSRegularExpression *findRegularExpression;
@property (readwrite,copy,nonatomic) NSString *statusString;

- (void)_addFindTextAttributes;
- (void)_removeFindTextAttributes;
- (NSRange)_nextRangeDidWrap:(BOOL *)didWrap includeSelectedRange:(BOOL)includeSelectedRange;
- (NSRange)_previousRangeDidWrap:(BOOL *)didWrap;
@end

@implementation RSFindBarViewController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_textView = nil;
	[_findString release];
	[_lastFindString release];
	[_findRegularExpression release];
	[_statusString release];
	[_findRanges release];
	[_showFindBarAnimation release];
	[_hideFindBarAnimation release];
	[_findOptionsViewController release];
	[super dealloc];
}

- (void)loadView {
	[super loadView];
	
	[(NSSearchFieldCell *)[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"String Searching", @"find bar search field placeholder string")];
}

- (void)animationDidStop:(NSAnimation *)animation {
	if (animation == _showFindBarAnimation) {
		[_showFindBarAnimation release];
		_showFindBarAnimation = nil;
	}
	else if (animation == _hideFindBarAnimation) {
		[_hideFindBarAnimation release];
		_hideFindBarAnimation = nil;
	}
}
- (void)animationDidEnd:(NSAnimation *)animation {
	if (animation == _showFindBarAnimation) {
		[_showFindBarAnimation release];
		_showFindBarAnimation = nil;
		
		[[[self view] window] makeFirstResponder:[self searchField]];
		
		if ([[self findString] length])
			[self find:nil];
	}
	else if (animation == _hideFindBarAnimation) {
		[_hideFindBarAnimation release];
		_hideFindBarAnimation = nil;
		
		[[self view] removeFromSuperviewWithoutNeedingDisplay];
	}
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if (commandSelector == @selector(cancelOperation:)) {
		[self hideFindBar:nil];
		return YES;
	}
	else if (commandSelector == @selector(insertNewline:)) {
		if ([_findRanges count])
			[self findNext:nil];
		else if ([[self findString] length])
			[self find:nil];
	}
	return NO;
}

- (void)findOptionsViewControllerDidChangeFindOptions:(RSFindOptionsViewController *)viewController {
	if ([[self findString] length])
		[self find:nil];
}

- (id)initWithTextView:(NSTextView *)textView {
	if (!(self = [super initWithNibName:@"RSFindBarView" bundle:nil]))
		return nil;
	
	_textView = textView;
	_findFlags.wrapAround = YES;
	_findRanges = [[NSPointerArray pointerArrayForRanges] retain];
	_findOptionsViewController = [[RSFindOptionsViewController alloc] init];
	[_findOptionsViewController setDelegate:self];
	
	return self;
}

+ (NSDictionary *)findTextAttributes; {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSColor yellowColor],NSBackgroundColorAttributeName,[NSColor orangeColor],NSUnderlineColorAttributeName,[NSNumber numberWithUnsignedInteger:NSUnderlinePatternSolid|NSUnderlineStyleThick],NSUnderlineStyleAttributeName, nil];
}

- (IBAction)toggleFindBar:(id)sender; {
	if ([self isFindBarVisible])
		[self hideFindBar:nil];
	else
		[self showFindBar:nil];
}
static const NSTimeInterval kFindBarShowHideDelay = 0.25;
static const NSAnimationCurve kFindBarShowHideAnimationCurve = NSAnimationEaseIn;
- (IBAction)showFindBar:(id)sender; {
	if ([self isFindBarVisible]) {
		[[[self view] window] makeFirstResponder:[self searchField]];
		return;
	}
	
	[[[[self textView] window] contentView] addSubview:[self view] positioned:NSWindowBelow relativeTo:[[[[[self textView] window] contentView] subviews] objectAtIndex:0]];
	
	NSRect scrollViewFrame = [[[self textView] enclosingScrollView] frame];
	NSRect findBarFrame = [[self view] frame];
	
	_showFindBarAnimation = [[NSViewAnimation alloc] initWithDuration:kFindBarShowHideDelay animationCurve:kFindBarShowHideAnimationCurve];
	[_showFindBarAnimation setDelegate:self];
	[_showFindBarAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[_showFindBarAnimation setViewAnimations:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[self view],NSViewAnimationTargetKey,[NSValue valueWithRect:NSMakeRect(NSMinX(scrollViewFrame), NSMaxY(scrollViewFrame), NSWidth(scrollViewFrame), NSHeight(findBarFrame))],NSViewAnimationStartFrameKey,[NSValue valueWithRect:NSMakeRect(NSMinX(scrollViewFrame), NSMaxY(scrollViewFrame)-NSHeight(findBarFrame), NSWidth(scrollViewFrame), NSHeight(findBarFrame))],NSViewAnimationEndFrameKey, nil],[NSDictionary dictionaryWithObjectsAndKeys:[[self textView] enclosingScrollView],NSViewAnimationTargetKey,[NSValue valueWithRect:NSMakeRect(NSMinX(scrollViewFrame), NSMinY(scrollViewFrame), NSWidth(scrollViewFrame), NSHeight(scrollViewFrame)-NSHeight(findBarFrame))],NSViewAnimationEndFrameKey, nil], nil]];
	
	[_showFindBarAnimation startAnimation];
}
- (IBAction)hideFindBar:(id)sender; {
	[[[self textView] window] makeFirstResponder:[self textView]];
	[self _removeFindTextAttributes];
	
	NSRect scrollViewFrame = [[[self textView] enclosingScrollView] frame];
	NSRect findBarFrame = [[self view] frame];
	
	_hideFindBarAnimation = [[NSViewAnimation alloc] initWithDuration:kFindBarShowHideDelay animationCurve:kFindBarShowHideAnimationCurve];
	[_hideFindBarAnimation setDelegate:self];
	[_hideFindBarAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[_hideFindBarAnimation setViewAnimations:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[self view],NSViewAnimationTargetKey,[NSValue valueWithRect:NSMakeRect(NSMinX(scrollViewFrame), NSMaxY(scrollViewFrame)+NSHeight(findBarFrame), NSWidth(findBarFrame), NSHeight(findBarFrame))],NSViewAnimationEndFrameKey, nil],[NSDictionary dictionaryWithObjectsAndKeys:[[self textView] enclosingScrollView],NSViewAnimationTargetKey,[NSValue valueWithRect:NSMakeRect(NSMinX(scrollViewFrame), NSMinY(scrollViewFrame), NSWidth(scrollViewFrame), NSHeight(scrollViewFrame)+NSHeight(findBarFrame))],NSViewAnimationEndFrameKey, nil], nil]];
	
	[_hideFindBarAnimation startAnimation];
}

- (void)showFindOptions:(id)sender {
	NSRect rect = [(NSSearchFieldCell *)[[self searchField] cell] searchButtonRectForBounds:[[self searchField] bounds]];
	[[self findOptionsViewController] showFindOptionsViewRelativeToRect:rect ofView:[self searchField] preferredEdge:NSMaxYEdge];
}

- (IBAction)find:(id)sender; {
	[self setStatusString:nil];
	[_findRanges setCount:0];
	[self _removeFindTextAttributes];
	
	if (![[self findString] length]) {
		NSBeep();
		return;
	}
	else if ([[self findOptionsViewController] findStyle] == RSFindOptionsFindStyleRegularExpression) {
		NSRegularExpressionOptions regexOptions = 0;
		if (![[self findOptionsViewController] matchCase])
			regexOptions |= NSRegularExpressionCaseInsensitive;
		if ([[self findOptionsViewController] anchorsMatchLines])
			regexOptions |= NSRegularExpressionAnchorsMatchLines;
		if ([[self findOptionsViewController] dotMatchesNewlines])
			regexOptions |= NSRegularExpressionDotMatchesLineSeparators;
		
		NSRegularExpression *findRegex = [NSRegularExpression regularExpressionWithPattern:[self findString] options:regexOptions error:NULL];
		if (!findRegex) {
			[self setFindRegularExpression:nil];
			return;
		}
		[self setFindRegularExpression:findRegex];
	}
	
	NSString *string = [[self textView] string];
	NSUInteger stringLength = [string length];
	NSRange searchRange = NSMakeRange(0, stringLength);
	NSStringCompareOptions options = ([[self findOptionsViewController] matchCase])?NSLiteralSearch:(NSCaseInsensitiveSearch|NSLiteralSearch);
	RSFindOptionsMatchStyle matchStyle = [[self findOptionsViewController] matchStyle];
	
	CFLocaleRef currentLocale = CFLocaleCopyCurrent();
	// the CFStringTokenizer documentation says to pass kCFStringTokenizerUnitWordBoundary to do whole word searching
	CFStringTokenizerRef stringTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef)string, CFRangeMake(0, (CFIndex)stringLength), kCFStringTokenizerUnitWordBoundary, currentLocale);
	// release the copy of the current locale we were given
	CFRelease(currentLocale);
	
	if ([[self findOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual) {
		while (searchRange.location < stringLength) {
			NSRange foundRange = [string rangeOfString:[self findString] options:options range:searchRange];
			if (foundRange.location == NSNotFound)
				break;
			
			CFStringTokenizerGoToTokenAtIndex(stringTokenizer, (CFIndex)foundRange.location);
			CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(stringTokenizer);
			
			switch (matchStyle) {
					// token range doesn't matter in this case
				case RSFindOptionsMatchStyleContains:
					[_findRanges addPointer:(void *)&foundRange];
					break;
					// token range and found range starting indexes must match and match range can't be longer than token range
				case RSFindOptionsMatchStyleStartsWith:
					if (foundRange.location == tokenRange.location &&
						foundRange.length < tokenRange.length)
						[_findRanges addPointer:(void *)&foundRange];
					break;
					// the ending indexes of token range and found range must match
				case RSFindOptionsMatchStyleEndsWith:
					if (NSMaxRange(foundRange) == (tokenRange.location + tokenRange.length))
						[_findRanges addPointer:(void *)&foundRange];
					break;
					// token range and found range must match exactly
				case RSFindOptionsMatchStyleWholeWord:
					if (foundRange.location == tokenRange.location &&
						foundRange.length == tokenRange.length)
						[_findRanges addPointer:(void *)&foundRange];
					break;
				default:
					break;
			}
			
			searchRange = NSMakeRange(NSMaxRange(foundRange), stringLength-NSMaxRange(foundRange));
		}
	}
	else {
		[[self findRegularExpression] enumerateMatchesInString:string options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSRange foundRange = [result range];
			
			CFStringTokenizerGoToTokenAtIndex(stringTokenizer, (CFIndex)foundRange.location);
			CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(stringTokenizer);
			
			switch (matchStyle) {
					// token range doesn't matter in this case
				case RSFindOptionsMatchStyleContains:
					[_findRanges addPointer:(void *)&foundRange];
					break;
					// token range and found range starting indexes must match and match range can't be longer than token range
				case RSFindOptionsMatchStyleStartsWith:
					if (foundRange.location == tokenRange.location &&
						foundRange.length < tokenRange.length)
						[_findRanges addPointer:(void *)&foundRange];
					break;
					// the ending indexes of token range and found range must match
				case RSFindOptionsMatchStyleEndsWith:
					if (NSMaxRange(foundRange) == (tokenRange.location + tokenRange.length))
						[_findRanges addPointer:(void *)&foundRange];
					break;
					// token range and found range must match exactly
				case RSFindOptionsMatchStyleWholeWord:
					if (foundRange.location == tokenRange.location &&
						foundRange.length == tokenRange.length)
						[_findRanges addPointer:(void *)&foundRange];
					break;
				default:
					break;
			}
		}];
	}
	
	// release our tokenizer from above
	CFRelease(stringTokenizer);
	
	if (![_findRanges count]) {
		[self setStatusString:NSLocalizedString(@"Not found", @"Not found")];
		return;
	}
	else if ([_findRanges count] == 1)
		[self setStatusString:NSLocalizedString(@"1 match", @"1 match")];
	else
		[self setStatusString:[NSString stringWithFormat:NSLocalizedString(@"%lu matches", @"find bar multiple matches status string"),[_findRanges count]]];
	
	NSMutableArray *recentSearches = [[[[self searchField] recentSearches] mutableCopy] autorelease];
	
	if (![recentSearches containsObject:[self findString]]) {
		[recentSearches addObject:[self findString]];
		[[self searchField] setRecentSearches:recentSearches];
	}
	
	[self _addFindTextAttributes];
}
- (IBAction)findNext:(id)sender; {
	if (![[self findString] length]) {
		NSBeep();
		return;
	}
	
	BOOL didWrap = NO;
	NSRange foundRange = [self _nextRangeDidWrap:&didWrap includeSelectedRange:NO];
	
	if (foundRange.location == NSNotFound) {
		NSBeep();
		//if (![self wrapAround])
			//[[RSBezelWindowManager sharedBezelWindowManager] showImage:[NSImage imageNamed:@"FindNoWrapIndicator"] inView:[[[self textView] enclosingScrollView] contentView]];
	}
	else {
		[[self textView] setSelectedRange:foundRange];
		[[self textView] scrollRangeToVisible:foundRange];
		[[self textView] showFindIndicatorForRange:foundRange];
		
		//if (didWrap)
		//	[[RSBezelWindowManager sharedBezelWindowManager] showImage:[NSImage imageNamed:@"FindWrapIndicator"] inView:[[[self textView] enclosingScrollView] contentView]];
	}
}
- (IBAction)findPrevious:(id)sender; {
	if (![[self findString] length]) {
		NSBeep();
		return;
	}
	
	BOOL didWrap = NO;
	NSRange foundRange = [self _previousRangeDidWrap:&didWrap];
	
	if (foundRange.location == NSNotFound) {
		NSBeep();
		//if (![self wrapAround])
		//	[[RSBezelWindowManager sharedBezelWindowManager] showImage:[NSImage imageNamed:@"FindNoWrapIndicatorReverse"] inView:[[[self textView] enclosingScrollView] contentView]];
	}
	else {
		[[self textView] setSelectedRange:foundRange];
		[[self textView] scrollRangeToVisible:foundRange];
		[[self textView] showFindIndicatorForRange:foundRange];
		
		//if (didWrap)
		//	[[RSBezelWindowManager sharedBezelWindowManager] showImage:[NSImage imageNamed:@"FindWrapIndicatorReverse"] inView:[[[self textView] enclosingScrollView] contentView]];
	}
}

@synthesize searchField=_searchField;
@synthesize findString=_findString;
@synthesize statusString=_statusString;
@dynamic wrapAround;
- (BOOL)wrapAround {
	return _findFlags.wrapAround;
}
- (void)setWrapAround:(BOOL)wrapAround {
	_findFlags.wrapAround = wrapAround;
}
@dynamic findBarVisible;
- (BOOL)isFindBarVisible {
	return ([[self view] window] != nil);
}
@synthesize textView=_textView;
@synthesize lastFindString=_lastFindString;
@synthesize findOptionsViewController=_findOptionsViewController;
@synthesize findRegularExpression=_findRegularExpression;

- (void)_addFindTextAttributes {	
	NSDictionary *attributes = [[self class] findTextAttributes];
	NSUInteger rangeIndex, rangeCount = [_findRanges count];
	for (rangeIndex = 0; rangeIndex < rangeCount; rangeIndex++) {
		NSRange range = *(NSRangePointer)[_findRanges pointerAtIndex:rangeIndex];
		
		[[[self textView] layoutManager] addTemporaryAttributes:attributes forCharacterRange:range];
	}
}
- (void)_removeFindTextAttributes {
	[[[self textView] layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[[self textView] string] length])];
	[[[self textView] layoutManager] removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:NSMakeRange(0, [[[self textView] string] length])];
	[[[self textView] layoutManager] removeTemporaryAttribute:NSUnderlineColorAttributeName forCharacterRange:NSMakeRange(0, [[[self textView] string] length])];
}

- (NSRange)_nextRangeDidWrap:(BOOL *)didWrap includeSelectedRange:(BOOL)includeSelectedRange; {
	NSString *string = [[self textView] string];
	NSRange selectedRange = [[self textView] selectedRange];
	NSRange searchRange = (includeSelectedRange)?NSMakeRange(selectedRange.location, [string length]-selectedRange.location):NSMakeRange(NSMaxRange(selectedRange), [string length]-NSMaxRange(selectedRange));
	NSStringCompareOptions options;
	NSRange foundRange;
	
	if ([[self findOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual) {
		options = ([[self findOptionsViewController] matchCase])?NSLiteralSearch:(NSCaseInsensitiveSearch|NSLiteralSearch);
		foundRange = [[[self textView] string] rangeOfString:[self findString] options:options range:searchRange];
	}
	else
		foundRange = [[self findRegularExpression] rangeOfFirstMatchInString:[[self textView] string] options:0 range:searchRange];
	
	if (foundRange.location == NSNotFound && [self wrapAround]) {
		if (didWrap != NULL)
			*didWrap = YES;
		
		if (includeSelectedRange)
			searchRange = NSMakeRange(0, NSMaxRange(selectedRange));
		else
			searchRange = NSMakeRange(0, selectedRange.location);
		
		if ([[self findOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual)
			foundRange = [[[self textView] string] rangeOfString:[self findString] options:options range:searchRange];
		else
			foundRange = [[self findRegularExpression] rangeOfFirstMatchInString:[[self textView] string] options:0 range:searchRange];
	}
	return foundRange;
}
- (NSRange)_previousRangeDidWrap:(BOOL *)didWrap; {
	NSRange selectedRange = [[self textView] selectedRange];
	NSStringCompareOptions options;
	NSRange foundRange;
	
	if ([[self findOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual) {
		options = ([[self findOptionsViewController] matchCase])?(NSLiteralSearch|NSBackwardsSearch):(NSBackwardsSearch|NSCaseInsensitiveSearch|NSLiteralSearch);
		foundRange = [[[self textView] string] rangeOfString:[self findString] options:options range:NSMakeRange(0, selectedRange.location)];
	}
	else {
		// TODO: this might be really slow, but i don't know another way to get the last match from NSRegularExpression
		NSArray *foundMatches = [[self findRegularExpression] matchesInString:[[self textView] string] options:0 range:NSMakeRange(0, selectedRange.location)];
		NSTextCheckingResult *lastMatch = [foundMatches lastObject];
		if (lastMatch)
			foundRange = [lastMatch range];
		else
			foundRange = NSNotFoundRange;
	}
	
	if (foundRange.location == NSNotFound && [self wrapAround]) {
		if (didWrap != NULL)
			*didWrap = YES;
		
		if ([[self findOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual)
			foundRange = [[[self textView] string] rangeOfString:[self findString] options:options range:NSMakeRange(NSMaxRange(selectedRange), [[[self textView] string] length]-NSMaxRange(selectedRange))];
		else {
			// TODO: this might be really slow, but i don't know another way to get the last match from NSRegularExpression
			NSArray *foundMatches = [[self findRegularExpression] matchesInString:[[self textView] string] options:0 range:NSMakeRange(NSMaxRange(selectedRange), [[[self textView] string] length]-NSMaxRange(selectedRange))];
			NSTextCheckingResult *lastMatch = [foundMatches lastObject];
			if (lastMatch)
				foundRange = [lastMatch range];
			else
				foundRange = NSNotFoundRange;
		}
	}
	return foundRange;
}
@end
