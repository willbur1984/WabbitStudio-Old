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
#import "WCStandardSourceTextViewController.h"
#import "WCSourceSymbol.h"
#import "WCProjectDocument.h"
#import "WCLayoutManager.h"
#import "WCSourceToken.h"

@interface WCSourceTextViewController ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCStandardSourceTextViewController *standardSourceTextViewController;
@property (readwrite,assign,nonatomic) NSRange additionalRangeToSyntaxHighlight;
@end

@implementation WCSourceTextViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	
	[[[self scrollView] contentView] setAutoresizesSubviews:YES];
	
	WCLayoutManager *layoutManager = [[[WCLayoutManager alloc] init] autorelease];
	
	[[self textStorage] addLayoutManager:layoutManager];
	
	NSSize contentSize = [[self scrollView] contentSize];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:contentSize] autorelease];
	
	[layoutManager addTextContainer:textContainer];
	
	WCSourceTextView *textView = [[[WCSourceTextView alloc] initWithFrame:[[[self scrollView] contentView] frame] textContainer:textContainer] autorelease];
	
	[textView setDelegate:self];
	
	[self setTextView:textView];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorWrapLinesToEditorWidthKey]) {
		[[self scrollView] setHasHorizontalScroller:NO];
		[textView setHorizontallyResizable:YES];
		[textContainer setWidthTracksTextView:YES];
		[textContainer setContainerSize:NSMakeSize(contentSize.width, CGFLOAT_MAX)];
	} else {
		[[self scrollView] setHasHorizontalScroller:YES];
		[textView setHorizontallyResizable:YES];
		[textContainer setContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
		[textContainer setWidthTracksTextView:NO];
	}
	[textView setTextContainerInset:NSMakeSize(1.0, 0.0)];
	
	[[self scrollView] setDocumentView:textView];
	
	WCSourceRulerView *rulerView = [[[WCSourceRulerView alloc] initWithScrollView:[[self textView] enclosingScrollView] orientation:NSVerticalRuler] autorelease];
	
	[rulerView setClientView:[self textView]];
	
	[[[self textView] enclosingScrollView] setVerticalRulerView:rulerView];
	
	[[[self textView] enclosingScrollView] setHasHorizontalScroller:NO];
	[[[self textView] enclosingScrollView] setHasVerticalRuler:YES];
	[[[self textView] enclosingScrollView] setRulersVisible:YES];
	
	[[self view] addSubview:[[self jumpBarViewController] view]];
	
	NSRect scrollViewFrame = [[self scrollView] frame];
	NSRect jumpBarFrame = [[[self jumpBarViewController] view] frame];
	
	[[self scrollView] setFrame:NSMakeRect(NSMinX(scrollViewFrame), NSMinY(scrollViewFrame), NSWidth(scrollViewFrame), NSHeight(scrollViewFrame)-NSHeight(jumpBarFrame))];
	[[[self jumpBarViewController] view] setFrame:NSMakeRect(NSMinX(scrollViewFrame), NSMaxY(scrollViewFrame)-NSHeight(jumpBarFrame), NSWidth(scrollViewFrame), NSHeight(jumpBarFrame))];
	
	[[self textView] setSelectedRange:NSEmptyRange];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewFrameDidChangeNotification object:[self textView]];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	return [[self standardSourceTextViewController] validateMenuItem:menuItem];
}

#pragma mark NSTextViewDelegate
- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if (commandSelector == @selector(insertNewline:)) {
		if ([textView selectedRange].location >= [[textView string] length])
			return NO;
		
		id attachment = [[textView textStorage] attribute:NSAttachmentAttributeName atIndex:[textView selectedRange].location effectiveRange:NULL];
		if ([[attachment attachmentCell] isKindOfClass:[WCArgumentPlaceholderCell class]]) {			
			[self textView:textView doubleClickedOnCell:[attachment attachmentCell] inRect:NSZeroRect atIndex:[textView selectedRange].location];
			return YES;
		}
	}
	return NO;
}

- (void)textView:(NSTextView *)textView clickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
	if ([cell isKindOfClass:[WCArgumentPlaceholderCell class]]) {
		[textView setSelectedRange:NSMakeRange(charIndex, 1)];
	}
}
- (void)textView:(NSTextView *)textView doubleClickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
	if ([cell isKindOfClass:[WCArgumentPlaceholderCell class]]) {
		if ([[(WCArgumentPlaceholderCell *)cell argumentChoices] count]) {
			NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
			[menu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
			[menu setShowsStateColumn:NO];
			NSImage *image = [WCSourceToken sourceTokenIconForSourceTokenType:[(WCArgumentPlaceholderCell *)cell argumentChoicesType]];
			
			for (NSString *choice in [(WCArgumentPlaceholderCell *)cell argumentChoices]) {
				NSMenuItem *item = [menu addItemWithTitle:choice action:@selector(_argumentPlaceholderMenuItemClicked:) keyEquivalent:@""];
				[item setTarget:self];
				[item setImage:image];
				[[item image] setSize:NSMakeSize(14.0, 14.0)];
			}
			
			NSUInteger glyphIndex = [[textView layoutManager] glyphIndexForCharacterAtIndex:charIndex];
			NSRect lineRect = [[textView layoutManager] lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
			NSPoint selectedPoint = [[textView layoutManager] locationForGlyphAtIndex:glyphIndex];
			
			lineRect.origin.y += lineRect.size.height;
			lineRect.origin.x += selectedPoint.x;
			
			NSCursor *currentCursor = [[textView enclosingScrollView] documentCursor];
			
			if ([menu popUpMenuPositioningItem:[menu itemAtIndex:0] atLocation:lineRect.origin inView:textView]) {
				NSString *title = [[menu highlightedItem] title];
				
				[textView insertText:title replacementRange:NSMakeRange(charIndex, 1)];
				[textView setSelectedRange:NSMakeRange(charIndex, [title length])];
			}
			else
				[currentCursor push];
		}
		else {
			[textView insertText:[(WCArgumentPlaceholderCell *)cell stringValue] replacementRange:NSMakeRange(charIndex, 1)];
			[textView setSelectedRange:NSMakeRange(charIndex, [[(WCArgumentPlaceholderCell *)cell stringValue] length])];
		}
	}
}
- (NSDictionary *)textView:(NSTextView *)textView shouldChangeTypingAttributes:(NSDictionary *)oldTypingAttributes toAttributes:(NSDictionary *)newTypingAttributes; {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[[self textStorage] paragraphStyle],NSParagraphStyleAttributeName, nil];
}
- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray *)affectedRanges replacementStrings:(NSArray *)replacementStrings {
	if ([affectedRanges count] == 1 &&
		NSMaxRange([[affectedRanges lastObject] rangeValue]) > NSMaxRange([textView visibleRange])) {
		
		[self setAdditionalRangeToSyntaxHighlight:[[affectedRanges lastObject] rangeValue]];
	}
	return YES;
}
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)view {
	return [[self sourceFileDocument] undoManager];
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
	
	NSArray *labelNamesArray = [[self sourceFileDocument] labelSymbolsForSourceHighlighter:[self sourceHighlighter]];
	NSArray *equateNamesArray = [[self sourceFileDocument] equateSymbolsForSourceHighlighter:[self sourceHighlighter]];
	NSArray *defineNamesArray = [[self sourceFileDocument] defineSymbolsForSourceHighlighter:[self sourceHighlighter]];
	NSArray *macroNamesArray = [[self sourceFileDocument] macroSymbolsForSourceHighlighter:[self sourceHighlighter]];
	
	for (NSDictionary *labelNames in labelNamesArray) {
		if ([labelNames objectForKey:name]) {
			[retval addObjectsFromArray:[[labelNames objectForKey:name] allObjects]];
			break;
		}
	}
	for (NSDictionary *equateNames in equateNamesArray) {
		if ([equateNames objectForKey:name]) {
			[retval addObjectsFromArray:[[equateNames objectForKey:name] allObjects]];
			break;
		}
	}
	for (NSDictionary *defineNames in defineNamesArray) {
		if ([defineNames objectForKey:name]) {
			[retval addObjectsFromArray:[[defineNames objectForKey:name] allObjects]];
			break;
		}
	}
	for (NSDictionary *macroNames in macroNamesArray) {
		if ([macroNames objectForKey:name]) {
			[retval addObjectsFromArray:[[macroNames objectForKey:name] allObjects]];
			break;
		}
	}
	
	[retval sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 rangeValue].location < [obj2 rangeValue].location)
			return NSOrderedAscending;
		else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
			return NSOrderedDescending;
		return NSOrderedSame;
	}]]];
	
	return [[retval copy] autorelease];
}
- (WCSourceScanner *)sourceScannerForSourceTextView:(WCSourceTextView *)textView {
	return [self sourceScanner];
}
- (WCSourceHighlighter *)sourceHighlighterForSourceTextView:(WCSourceTextView *)textView; {
	return [self sourceHighlighter];
}
- (void)handleJumpToDefinitionForSourceTextView:(WCSourceTextView *)textView sourceSymbol:(WCSourceSymbol *)symbol {
	if ([symbol sourceScanner] == [self sourceScanner]) {
		[textView setSelectedRange:[symbol range]];
		[textView scrollRangeToVisible:[symbol range]];
	}
	else {
		WCSourceTextViewController *stvController = [[[self sourceFileDocument] projectDocument] openTabForSourceFileDocument:[[[symbol sourceScanner] delegate] sourceFileDocumentForSourceScanner:[symbol sourceScanner]]];
		
		[[stvController textView] setSelectedRange:[symbol range]];
		[[stvController textView] scrollRangeToVisible:[symbol range]];
	}
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
	_additionalRangeToSyntaxHighlight = NSNotFoundRange;
	
	return self;
}

- (void)performCleanup; {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_scrollingHighlightTimer invalidate];
	_scrollingHighlightTimer = nil;
	
	[[self textStorage] removeLayoutManager:[[self textView] layoutManager]];
	
	[[self jumpBarViewController] performCleanup];
}
#pragma mark IBActions
- (IBAction)showStandardEditor:(id)sender; {
	[[self standardSourceTextViewController] showStandardEditor:nil];
}
- (IBAction)showTopLevelItems:(id)sender; {
	[[self jumpBarViewController] showTopLevelItems:nil];
}
- (IBAction)showGroupItems:(id)sender; {
	[[self jumpBarViewController] showGroupItems:nil];
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
@synthesize scrollView=_scrollView;
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
@synthesize additionalRangeToSyntaxHighlight=_additionalRangeToSyntaxHighlight;
#pragma mark *** Private Methods ***

#pragma mark IBActions
- (IBAction)_argumentPlaceholderMenuItemClicked:(id)sender {
	
}

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
	
	if (NSEqualRanges(NSNotFoundRange, [self additionalRangeToSyntaxHighlight]))
		[[self sourceHighlighter] performHighlightingInRange:[[self textView] visibleRange]];
	else {
		[self setAdditionalRangeToSyntaxHighlight:NSNotFoundRange];
		
		NSRange visibleRange = [[self textView] visibleRange];
		NSRange rangeToColor = NSUnionRange(visibleRange, [self additionalRangeToSyntaxHighlight]);
		if (NSMaxRange(rangeToColor) > [[self textStorage] length])
			rangeToColor = NSMakeRange(visibleRange.location, [[self textStorage] length]-visibleRange.location);
		
		[[self sourceHighlighter] performHighlightingInRange:rangeToColor];
	}
}

@end
