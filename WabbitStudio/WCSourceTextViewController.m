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
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "WCEditorViewController.h"
#import "WCJumpBarViewController.h"
#import "WCSourceFileDocument.h"

@interface WCSourceTextViewController ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@end

@implementation WCSourceTextViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_jumpBarViewController release];
	_textStorage = nil;
	_sourceScanner = nil;
	_sourceHighlighter = nil;
	_sourceFileDocument = nil;
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCSourceTextView";
}

- (void)loadView {
	[super loadView];
	
	NSRect scrollViewFrame = [[[self textView] enclosingScrollView] frame];
	NSRect jumpBarFrame = [[[self jumpBarViewController] view] frame];
	
	[[self view] addSubview:[[self jumpBarViewController] view]];
	
	[[[self textView] enclosingScrollView] setFrame:NSMakeRect(NSMinX(scrollViewFrame), NSMinY(scrollViewFrame), NSWidth(scrollViewFrame), NSHeight(scrollViewFrame)-NSHeight(jumpBarFrame))];
	[[[self jumpBarViewController] view] setFrame:NSMakeRect(NSMinX(scrollViewFrame), NSMaxY(scrollViewFrame)-NSHeight(jumpBarFrame), NSWidth(scrollViewFrame), NSHeight(jumpBarFrame))];
	
	[[[self textView] layoutManager] replaceTextStorage:[self textStorage]];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[self textView] setFont:[currentTheme plainTextFont]];
	[[self textView] setTextColor:[currentTheme plainTextColor]];
	[[self textView] setDefaultParagraphStyle:[[self textStorage] paragraphStyle]];
	
	WCSourceRulerView *rulerView = [[[WCSourceRulerView alloc] initWithScrollView:[[self textView] enclosingScrollView] orientation:NSVerticalRuler] autorelease];
	
	[[[self textView] enclosingScrollView] setVerticalRulerView:rulerView];
	
	[[[self textView] enclosingScrollView] setHasHorizontalScroller:NO];
	[[[self textView] enclosingScrollView] setHasVerticalRuler:YES];
	[[[self textView] enclosingScrollView] setRulersVisible:YES];
	
	[[self textView] setSelectedRange:NSEmptyRange];
	
	[[self textView] setWrapLines:[[NSUserDefaults standardUserDefaults] boolForKey:WCEditorWrapLinesToEditorWidthKey]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[[[self textView] enclosingScrollView] contentView]];
}

- (void)textView:(NSTextView *)textView clickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
	if (![cell isKindOfClass:[WCArgumentPlaceholderCell class]])
		return;
	
	[textView setSelectedRange:NSMakeRange(charIndex, 1)];
}
- (NSDictionary *)textView:(NSTextView *)textView shouldChangeTypingAttributes:(NSDictionary *)oldTypingAttributes toAttributes:(NSDictionary *)newTypingAttributes; {
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[[self textStorage] paragraphStyle],NSParagraphStyleAttributeName, nil];
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
- (WCSourceHighlighter *)sourceHighlighterForSourceTextView:(WCSourceTextView *)textView; {
	return [self sourceHighlighter];
}

- (id)initWithTextStorage:(WCSourceTextStorage *)textStorage sourceScanner:(WCSourceScanner *)sourceScanner sourceHighlighter:(WCSourceHighlighter *)sourceHighlighter; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_textStorage = textStorage;
	_sourceScanner = sourceScanner;
	_sourceHighlighter = sourceHighlighter;
	
	return self;
}
- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	if (!(self = [super initWithNibName:@"WCSourceTextView" bundle:nil]))
		return nil;
	
	_sourceFileDocument = sourceFileDocument;
	_textStorage = [sourceFileDocument textStorage];
	_sourceScanner = [sourceFileDocument sourceScanner];
	_sourceHighlighter = [sourceFileDocument sourceHighlighter];
	
	return self;
}

@synthesize textView=_textView;
@synthesize sourceScanner=_sourceScanner;
@synthesize textStorage=_textStorage;
@synthesize sourceHighlighter=_sourceHighlighter;
@dynamic jumpBarViewController;
- (WCJumpBarViewController *)jumpBarViewController {
	if (!_jumpBarViewController) {
		_jumpBarViewController = [[WCJumpBarViewController alloc] initWithTextView:[self textView] jumpBarDataSource:_sourceFileDocument];
	}
	return _jumpBarViewController;
}

- (void)_viewBoundsDidChange:(NSNotification *)note {
	static const NSTimeInterval kScrollingHighlightTimerDelay = 0.1;
	if (_scrollingHighlightTimer)
		[_scrollingHighlightTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kScrollingHighlightTimerDelay]];
	else {
		_scrollingHighlightTimer = [NSTimer timerWithTimeInterval:kScrollingHighlightTimerDelay target:self selector:@selector(_scrollingHighlightTimerCallback:) userInfo:nil repeats:NO];
		[[NSRunLoop mainRunLoop] addTimer:_scrollingHighlightTimer forMode:NSRunLoopCommonModes];
	}
}

- (void)_scrollingHighlightTimerCallback:(NSTimer *)timer {
	[_scrollingHighlightTimer invalidate];
	_scrollingHighlightTimer = nil;
	
	[[self sourceHighlighter] performHighlightingInRange:[[self textView] visibleRange]];
}

@end
