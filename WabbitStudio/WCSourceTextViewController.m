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
#import "NSView+MCExtensions.h"
#import "WCStandardSourceTextViewController.h"

@interface WCSourceTextViewController ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCStandardSourceTextViewController *standardSourceTextViewController;
@end

@implementation WCSourceTextViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[self view] setViewController:nil];
	[_scrollingHighlightTimer invalidate];
	_scrollingHighlightTimer = nil;
	_standardSourceTextViewController = nil;
	[_jumpBarViewController release];
	_sourceFileDocument = nil;
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCSourceTextView";
}

- (void)loadView {
	[super loadView];
	
	[[self view] setViewController:self];
	
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
	
	[rulerView setClientView:[self textView]];
	
	[[[self textView] enclosingScrollView] setVerticalRulerView:rulerView];
	
	[[[self textView] enclosingScrollView] setHasHorizontalScroller:NO];
	[[[self textView] enclosingScrollView] setHasVerticalRuler:YES];
	[[[self textView] enclosingScrollView] setRulersVisible:YES];
	
	[[self textView] setSelectedRange:NSEmptyRange];
	
	[[self textView] setWrapLines:[[NSUserDefaults standardUserDefaults] boolForKey:WCEditorWrapLinesToEditorWidthKey]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[[[self textView] enclosingScrollView] contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewFrameDidChangeNotification object:[self textView]];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	return [[self standardSourceTextViewController] validateMenuItem:menuItem];
}

#pragma mark NSTextViewDelegate
- (void)textView:(NSTextView *)textView clickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
	if (![cell isKindOfClass:[WCArgumentPlaceholderCell class]])
		return;
	
	[textView setSelectedRange:NSMakeRange(charIndex, 1)];
}
- (NSDictionary *)textView:(NSTextView *)textView shouldChangeTypingAttributes:(NSDictionary *)oldTypingAttributes toAttributes:(NSDictionary *)newTypingAttributes; {
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[[self textStorage] paragraphStyle],NSParagraphStyleAttributeName, nil];
}

#pragma mark WCSourceTextViewDelegate
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
#pragma mark *** Public Methods ***
- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	return [self initWithSourceFileDocument:sourceFileDocument standardSourceTextViewController:nil];
}
- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument standardSourceTextViewController:(WCStandardSourceTextViewController *)sourceTextViewController; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_sourceFileDocument = sourceFileDocument;
	_standardSourceTextViewController = sourceTextViewController;
	
	return self;
}
#pragma mark IBActions
- (IBAction)showStandardEditor:(id)sender; {
	[[self standardSourceTextViewController] showStandardEditor:nil];
}
- (IBAction)showDocumentItems:(id)sender; {
	[[self jumpBarViewController] showDocumentItems:nil];
}
- (IBAction)showAssistantEditor:(id)sender; {
	[[self standardSourceTextViewController] showAssistantEditor:nil];
}
- (IBAction)addAssistantEditor:(id)sender; {
	[[self standardSourceTextViewController] addAssistantEditorForSourceTextViewController:self];
}
- (IBAction)removeAssistantEditor:(id)sender; {
	[[self standardSourceTextViewController] removeAssistantEditorForSourceTextViewController:self];
}
#pragma mark Properties
@synthesize textView=_textView;
@dynamic sourceScanner;
- (WCSourceScanner *)sourceScanner {
	return [_sourceFileDocument sourceScanner];
}
@dynamic textStorage;
- (WCSourceTextStorage *)textStorage {
	return [_sourceFileDocument textStorage];
}
@dynamic sourceHighlighter;
- (WCSourceHighlighter *)sourceHighlighter {
	return [_sourceFileDocument sourceHighlighter];
}
@dynamic jumpBarViewController;
- (WCJumpBarViewController *)jumpBarViewController {
	if (!_jumpBarViewController) {
		_jumpBarViewController = [[WCJumpBarViewController alloc] initWithTextView:[self textView] jumpBarDataSource:_sourceFileDocument];
	}
	return _jumpBarViewController;
}
@synthesize standardSourceTextViewController=_standardSourceTextViewController;
@synthesize sourceFileDocument=_sourceFileDocument;
#pragma mark *** Private Methods ***

#pragma mark Notifications
- (void)_viewBoundsDidChange:(NSNotification *)note {
	static const NSTimeInterval kScrollingHighlightTimerDelay = 0.1;
	if (_scrollingHighlightTimer)
		[_scrollingHighlightTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kScrollingHighlightTimerDelay]];
	else {
		_scrollingHighlightTimer = [NSTimer timerWithTimeInterval:kScrollingHighlightTimerDelay target:self selector:@selector(_scrollingHighlightTimerCallback:) userInfo:nil repeats:NO];
		[[NSRunLoop mainRunLoop] addTimer:_scrollingHighlightTimer forMode:NSRunLoopCommonModes];
	}
}
#pragma mark Callbacks
- (void)_scrollingHighlightTimerCallback:(NSTimer *)timer {
	[_scrollingHighlightTimer invalidate];
	_scrollingHighlightTimer = nil;
	
	[[self sourceHighlighter] performHighlightingInRange:[[self textView] visibleRange]];
}

@end
