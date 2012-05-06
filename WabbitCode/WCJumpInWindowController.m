//
//  WCJumpInWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCJumpInWindowController.h"
#import "WCJumpInMatch.h"
#import "RSDefines.h"
#import "NSString+WCExtensions.h"
#import "WCJumpInSearchOperation.h"
#import "WCReallyAdvancedViewController.h"

@interface WCJumpInWindowController ()
@property (readwrite,copy,nonatomic) NSArray *items;
@property (readwrite,assign,nonatomic) id <WCJumpInDataSource> dataSource;
@end

@implementation WCJumpInWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_matches = [[NSMutableArray alloc] initWithCapacity:0];
	_operationQueue = [[NSOperationQueue alloc] init];
	[_operationQueue setMaxConcurrentOperationCount:1];
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCJumpInWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[self window] makeFirstResponder:[self searchField]];
	
	[[self tableView] setTarget:self];
	[[self tableView] setDoubleAction:@selector(_tableViewDoubleClick:)];
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
}

#pragma mark NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if (commandSelector == @selector(insertNewline:)) {
		[[self jumpButton] performClick:nil];
		return YES;
	}
	else if (commandSelector == @selector(cancelOperation:)) {
		[[self cancelButton] performClick:nil];
		return YES;
	}
	else if (commandSelector == @selector(moveUp:)) {
		NSIndexSet *indexes = [[self tableView] selectedRowIndexes];
		if (![indexes count] || ![indexes firstIndex])
			NSBeep();
		else {
			[[self tableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:[indexes firstIndex]-1] byExtendingSelection:NO];
			[[self tableView] scrollRowToVisible:[[[self tableView] selectedRowIndexes] firstIndex]];
		}
		return YES;
	}
	else if (commandSelector == @selector(moveDown:)) {
		NSIndexSet *indexes = [[self tableView] selectedRowIndexes];
		if (![indexes count] || [indexes firstIndex] == [[self matches] count]-1)
			NSBeep();
		else {
			[[self tableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:[indexes firstIndex]+1] byExtendingSelection:NO];
			[[self tableView] scrollRowToVisible:[[[self tableView] selectedRowIndexes] firstIndex]];
		}
		return YES;
	}
	return NO;
}
#pragma mark *** Public Methods ***
+ (WCJumpInWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (void)showJumpInWindowWithDataSource:(id <WCJumpInDataSource>)dataSource; {
	[self setDataSource:dataSource];
	
	[[self window] makeFirstResponder:[self searchField]];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCReallyAdvancedJumpInFileSearchUsingCurrentEditorSelectionKey]) {
		NSRange symbolRange = [[[[self dataSource] jumpInTextView] string] symbolRangeForRange:[[[self dataSource] jumpInTextView] selectedRange]];
		if (symbolRange.location != NSNotFound) {
			[self setSearchString:[[[[self dataSource] jumpInTextView] string] substringWithRange:symbolRange]];
			[self search:nil];
		}
	}
	
	NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
	
	if (result == NSOKButton) {
		WCJumpInMatch *match = [[[self arrayController] selectedObjects] lastObject];
		
		[[[self dataSource] jumpInTextView] setSelectedRange:[[match item] jumpInRange]];
		[[[self dataSource] jumpInTextView] centerSelectionInVisibleArea:nil];
		[[[self dataSource] jumpInTextView] showFindIndicatorForRange:[[match item] jumpInRange]];
	}
	
	[self setSearchString:nil];
	[self setStatusString:nil];
	[[self mutableMatches] removeAllObjects];
	[self setDataSource:nil];
}
#pragma mark IBActions
- (IBAction)jump:(id)sender; {
	[[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
	[[self window] orderOut:nil];
}
- (IBAction)cancel:(id)sender; {
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
	[[self window] orderOut:nil];
}

- (IBAction)search:(id)sender; {
	// require a search string of at least 2 characters, this matches Xcode's behavior
	if ([[self searchString] length] <= 1) {
		[[self mutableMatches] setArray:nil];
		[self setStatusString:nil];
		[self setSearching:NO];
		return;
	}
	
	[self setSearching:YES];
	
	[_operationQueue cancelAllOperations];
	[_operationQueue addOperation:[[[WCJumpInSearchOperation alloc] initWithJumpInWindowController:self] autorelease]];
}
#pragma mark Properties
@synthesize searchString=_searchString;
@synthesize matches=_matches;
@dynamic mutableMatches;
- (NSMutableArray *)mutableMatches {
	return [self mutableArrayValueForKey:@"matches"];
}
- (NSUInteger)countOfMatches {
	return [_matches count];
}
- (NSArray *)matchesAtIndexes:(NSIndexSet *)indexes {
	return [_matches objectsAtIndexes:indexes];
}
- (void)insertMatches:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_matches insertObjects:array atIndexes:indexes];
}
- (void)removeMatchesAtIndexes:(NSIndexSet *)indexes {
	[_matches removeObjectsAtIndexes:indexes];
}
- (void)replaceMatchesAtIndexes:(NSIndexSet *)indexes withMatches:(NSArray *)array {
	[_matches replaceObjectsAtIndexes:indexes withObjects:array];
}
@dynamic dataSource;
- (id <WCJumpInDataSource>)dataSource {
	return _dataSource;
}
- (void)setDataSource:(id <WCJumpInDataSource>)dataSource {
	_dataSource = dataSource;
	
	[self setItems:[dataSource jumpInItems]];
	
	if (dataSource)
		[[self window] setTitle:[NSString stringWithFormat:NSLocalizedString(@"Jump in \"%@\"", @"jump in window title format string"),[[self dataSource] jumpInFileName]]];
}
@synthesize statusString=_statusString;
@synthesize items=_items;
@synthesize arrayController=_arrayController;
@synthesize jumpButton=_jumpButton;
@synthesize cancelButton=_cancelButton;
@synthesize searchField=_searchField;
@synthesize tableView=_tableView;
@dynamic searching;
- (BOOL)isSearching {
	return _jumpInFlags.searching;
}
- (void)setSearching:(BOOL)searching {
	_jumpInFlags.searching = searching;
}
#pragma mark *** Private Methods ***

#pragma mark IBActions
- (IBAction)_tableViewDoubleClick:(id)sender {
	if (![[[self arrayController] selectedObjects] count]) {
		NSBeep();
		return;
	}
	
	[self jump:nil];
}
@end
