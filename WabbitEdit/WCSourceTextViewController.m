//
//  WCSourceTextViewController.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceTextViewController.h"
#import "WCSourceTextView.h"
#import "WCSourceScanner.h"
#import "WCSourceTextStorage.h"
#import "WCSourceRulerView.h"
#import "WCSourceHighlighter.h"
#import "NSTextView+WCExtensions.h"
#import "WCArgumentPlaceholderCell.h"
#import "RSDefines.h"
#import "WCEditorViewController.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"

@interface WCSourceTextViewController ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@property (readonly,nonatomic) WCSourceHighlighter *sourceHighlighter;
@end

@implementation WCSourceTextViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_completionTimer invalidate];
	_completionTimer = nil;
	_textStorage = nil;
	_sourceScanner = nil;
	_sourceHighlighter = nil;
	[super dealloc];
}

- (void)loadView {
	[super loadView];
	
	[[[self textView] layoutManager] replaceTextStorage:[self textStorage]];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[self textView] setFont:[currentTheme plainTextFont]];
	[[self textView] setTextColor:[currentTheme plainTextColor]];
	
	WCSourceRulerView *rulerView = [[[WCSourceRulerView alloc] initWithScrollView:[[self textView] enclosingScrollView] orientation:NSVerticalRuler] autorelease];
	
	[[[self textView] enclosingScrollView] setVerticalRulerView:rulerView];
	
	[[[self textView] enclosingScrollView] setHasHorizontalScroller:NO];
	[[[self textView] enclosingScrollView] setHasVerticalRuler:YES];
	[[[self textView] enclosingScrollView] setRulersVisible:YES];
	
	[[self textView] setSelectedRange:NSEmptyRange];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[[[self textView] enclosingScrollView] contentView]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[self textStorage]];
}

- (void)textView:(NSTextView *)textView clickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
	if (![cell isKindOfClass:[WCArgumentPlaceholderCell class]])
		return;
	
	[textView setSelectedRange:NSMakeRange(charIndex, 1)];
}
- (NSDictionary *)textView:(NSTextView *)textView shouldChangeTypingAttributes:(NSDictionary *)oldTypingAttributes toAttributes:(NSDictionary *)newTypingAttributes; {
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil];
}

- (NSArray *)sourceSymbolsForSourceTextView:(WCSourceTextView *)textView {
	return [[self sourceScanner] symbols];
}
- (NSArray *)sourceTokensForSourceTextView:(WCSourceTextView *)textView {
	return [[self sourceScanner] tokens];
}
- (NSArray *)sourceTextView:(WCSourceTextView *)textView sourceSymbolsForSymbolName:(NSString *)name {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	name = [name lowercaseString];
	
	if ([[[self sourceScanner] labelNamesToLabelSymbols] objectForKey:name])
		[retval addObjectsFromArray:[[[[self sourceScanner] labelNamesToLabelSymbols] objectForKey:name] allObjects]];
	if ([[[self sourceScanner] equateNamesToEquateSymbols] objectForKey:name])
		[retval addObjectsFromArray:[[[[self sourceScanner] equateNamesToEquateSymbols] objectForKey:name] allObjects]];
	if ([[[self sourceScanner] defineNamesToDefineSymbols] objectForKey:name])
		[retval addObjectsFromArray:[[[[self sourceScanner] defineNamesToDefineSymbols] objectForKey:name] allObjects]];
	if ([[[self sourceScanner] macroNamesToMacroSymbols] objectForKey:name])
		[retval addObjectsFromArray:[[[[self sourceScanner] macroNamesToMacroSymbols] objectForKey:name] allObjects]];
	
	return retval;
}
- (WCSourceScanner *)sourceScannerForSourceTextView:(WCSourceTextView *)textView {
	return [self sourceScanner];
}

- (id)initWithTextStorage:(WCSourceTextStorage *)textStorage sourceScanner:(WCSourceScanner *)sourceScanner sourceHighlighter:(WCSourceHighlighter *)sourceHighlighter; {
	if (!(self = [super initWithNibName:@"WCSourceTextView" bundle:nil]))
		return nil;
	
	_textStorage = textStorage;
	_sourceScanner = sourceScanner;
	_sourceHighlighter = sourceHighlighter;
	
	return self;
}

@synthesize textView=_textView;
@synthesize sourceScanner=_sourceScanner;
@synthesize textStorage=_textStorage;
@synthesize sourceHighlighter=_sourceHighlighter;

- (void)_viewBoundsDidChange:(NSNotification *)note {
	static const NSTimeInterval kScrollingHighlightTimerDelay = 0.1;
	if (_scrollingHighlightTimer)
		[_scrollingHighlightTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kScrollingHighlightTimerDelay]];
	else {
		_scrollingHighlightTimer = [NSTimer timerWithTimeInterval:kScrollingHighlightTimerDelay target:self selector:@selector(_scrollingHighlightTimerCallback:) userInfo:nil repeats:NO];
		[[NSRunLoop mainRunLoop] addTimer:_scrollingHighlightTimer forMode:NSRunLoopCommonModes];
	}
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	if (([[note object] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	else if (![[NSUserDefaults standardUserDefaults] boolForKey:WCEditorSuggestCompletionsWhileTypingKey])
		return;
	else if ([[[self textView] window] firstResponder] != [self textView] ||
			 [[note object] changeInLength] != 1 ||
			 [[self undoManager] isUndoing] ||
			 [[self undoManager] isRedoing]) {
		[_completionTimer invalidate];
		_completionTimer = nil;
		return;
	}
	
	static NSCharacterSet *legalChars;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableCharacterSet *charSet = [[[NSCharacterSet letterCharacterSet] mutableCopy] autorelease];
		[charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
		[charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_!?.#"]];
		legalChars = [charSet copy];
	});
	
	unichar charAtIndex = [[[self textView] string] characterAtIndex:[[note object] editedRange].location];
	if (![legalChars characterIsMember:charAtIndex]) {
		[_completionTimer invalidate];
		_completionTimer = nil;
		return;
	}
	
	CGFloat kCompletionTimerDelay = [[NSUserDefaults standardUserDefaults] floatForKey:WCEditorSuggestCompletionsWhileTypingDelayKey];
	
	if (_completionTimer)
		[_completionTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kCompletionTimerDelay]];
	else {
		_completionTimer = [NSTimer scheduledTimerWithTimeInterval:kCompletionTimerDelay target:self selector:@selector(_completionTimerCallback:) userInfo:nil repeats:NO];
	}
}

- (void)_completionTimerCallback:(NSTimer *)timer {
	[_completionTimer invalidate];
	_completionTimer = nil;
	
	[[self textView] complete:nil];
}

- (void)_scrollingHighlightTimerCallback:(NSTimer *)timer {
	[_scrollingHighlightTimer invalidate];
	_scrollingHighlightTimer = nil;
	
	[[self sourceHighlighter] performHighlightingInRange:[[self textView] visibleRange]];
}

@end
