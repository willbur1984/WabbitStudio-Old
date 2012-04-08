//
//  WCOpenQuicklyWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCOpenQuicklyWindowController.h"
#import "WCOpenQuicklyMatch.h"
#import "WCSourceFileDocument.h"
#import "WCProjectDocument.h"
#import "WCSourceTextViewController.h"
#import "WCOpenQuicklySearchOperation.h"
#import "WCSourceTextView.h"
#import "WCProjectWindowController.h"
#import "RSNavigatorControl.h"
#import "WCProjectNavigatorViewController.h"
#import "WCReallyAdvancedViewController.h"
#import "WCTabViewController.h"
#import "NSString+WCExtensions.h"

@interface WCOpenQuicklyWindowController ()
@property (readwrite,copy,nonatomic) NSArray *items;
@property (readwrite,assign,nonatomic) id <WCOpenQuicklyDataSource> dataSource;
@end

@implementation WCOpenQuicklyWindowController
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
	return @"WCOpenQuicklyWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[self window] makeFirstResponder:[self searchField]];
	
	[[self tableView] setTarget:self];
	[[self tableView] setDoubleAction:@selector(_tableViewDoubleClick:)];
	
	[[self pathControl] setTarget:self];
	[[self pathControl] setAction:@selector(_pathControlSingleClick:)];
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
}

#pragma mark NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if (commandSelector == @selector(insertNewline:)) {
		[[self openButton] performClick:nil];
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
+ (WCOpenQuicklyWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (void)showOpenQuicklyWindowWithDataSource:(id <WCOpenQuicklyDataSource>)dataSource; {
	[self setDataSource:dataSource];
	
	[[self window] makeFirstResponder:[self searchField]];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCReallyAdvancedOpenQuicklySearchUsingCurrentEditorSelectionKey]) {
		WCTabViewController *tabViewController = [[[[self dataSource] openQuicklyProjectDocument] currentTabViewContext] tabViewController];
		WCSourceFileDocument *sourceFileDocument = [[[tabViewController tabView] selectedTabViewItem] identifier];
		NSTextView *textView = [[[tabViewController sourceFileDocumentsToSourceTextViewControllers] objectForKey:sourceFileDocument] textView];
		NSRange symbolRange;
		
		if ([textView selectedRange].length)
			symbolRange = [textView selectedRange];
		else
			symbolRange = [[textView string] symbolRangeForRange:[textView selectedRange]];
		
		if (symbolRange.location != NSNotFound) {
			[self setSearchString:[[textView string] substringWithRange:symbolRange]];
			[self search:nil];
		}
	}
	
	NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
	
	if (result == NSOKButton) {
		WCOpenQuicklyMatch *match = [[[self arrayController] selectedObjects] lastObject];
		WCSourceFileDocument *sfDocument = [[match item] openQuicklySourceFileDocument];
		
		if (sfDocument) {
			WCSourceTextViewController *stvController = [[sfDocument projectDocument] openTabForSourceFileDocument:sfDocument tabViewContext:nil];
			
			[[stvController textView] setSelectedRange:[[match item] openQuicklyRange]];
			[[stvController textView] centerSelectionInVisibleArea:nil];
		}
		else {
			WCProjectDocument *projectDocument = [[self dataSource] openQuicklyProjectDocument];
			
			[[[projectDocument projectWindowController] navigatorControl] setSelectedItemIdentifier:WCProjectWindowNavigatorControlProjectItemIdentifier];
			[[[projectDocument projectWindowController] projectNavigatorViewController] setSelectedModelObjects:[NSArray arrayWithObjects:[match item], nil]];
		}
	}
	
	[self setSearchString:nil];
	[self setStatusString:nil];
	[[self mutableMatches] setArray:nil];
	[self setDataSource:nil];
}
#pragma mark IBActions
- (IBAction)open:(id)sender; {
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
	[_operationQueue addOperation:[[[WCOpenQuicklySearchOperation alloc] initWithOpenQuicklyWindowController:self] autorelease]];
}
#pragma mark Properties
@synthesize arrayController=_arrayController;
@synthesize openButton=_openButton;
@synthesize cancelButton=_cancelButton;
@synthesize searchField=_searchField;
@synthesize tableView=_tableView;
@synthesize pathControl=_pathControl;

@synthesize searchString=_searchString;
@synthesize statusString=_statusString;
@synthesize items=_items;
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
@dynamic searching;
- (BOOL)isSearching {
	return _openQuicklyFlags.searching;
}
- (void)setSearching:(BOOL)searching {
	_openQuicklyFlags.searching = searching;
}
@dynamic dataSource;
- (id <WCOpenQuicklyDataSource>)dataSource {
	return _dataSource;
}
- (void)setDataSource:(id <WCOpenQuicklyDataSource>)dataSource {
	_dataSource = dataSource;
	
	[self setItems:[dataSource openQuicklyItems]];
	
	if (dataSource)
		[[self window] setTitle:[NSString stringWithFormat:NSLocalizedString(@"Open Quickly in \"%@\"", @"open quickly window title format string"),[[[self dataSource] openQuicklyProjectName] stringByDeletingPathExtension]]];
}
#pragma mark *** Private Methods ***
- (IBAction)_tableViewDoubleClick:(id)sender {
	if (![[[self arrayController] selectedObjects] count]) {
		NSBeep();
		return;
	}
	
	[self open:nil];
}

- (IBAction)_pathControlSingleClick:(id)sender; {
	NSPathComponentCell *cell = [[self pathControl] clickedPathComponentCell];
	
	if (!cell) {
		NSBeep();
		return;
	}
	
	[[NSWorkspace sharedWorkspace] openURL:[cell URL]];
}
@end
