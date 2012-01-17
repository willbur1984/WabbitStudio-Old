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

@interface WCOpenQuicklyWindowController ()
@property (readwrite,copy,nonatomic) NSArray *items;
@property (readwrite,assign,nonatomic) id <WCOpenQuicklyDataSource> dataSource;
@end

@implementation WCOpenQuicklyWindowController

- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	
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
}

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
	
	NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
	
	if (result == NSOKButton) {
		WCOpenQuicklyMatch *match = [[[self arrayController] selectedObjects] lastObject];
		WCSourceFileDocument *sfDocument = [[match item] openQuicklySourceFileDocument];
		WCSourceTextViewController *stvController = [[sfDocument projectDocument] openTabForSourceFileDocument:sfDocument];
		
		[[stvController textView] setSelectedRange:[[match item] openQuicklyRange]];
		[[stvController textView] scrollRangeToVisible:[[match item] openQuicklyRange]];
	}
	
	[self setSearchString:nil];
	[self setStatusString:nil];
	[[self mutableMatches] setArray:nil];
	[self setDataSource:nil];
}

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

@synthesize arrayController=_arrayController;
@synthesize openButton=_openButton;
@synthesize cancelButton=_cancelButton;
@synthesize searchField=_searchField;
@synthesize tableView=_tableView;

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
@synthesize dataSource=_dataSource;

@end
