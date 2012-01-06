//
//  WCJumpInWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpInWindowController.h"
#import "WCJumpInMatch.h"
#import "RSDefines.h"
#import "NSString+WCExtensions.h"
#import "WCJumpInSearchOperation.h"

@interface WCJumpInWindowController ()
@property (readwrite,copy,nonatomic) NSArray *items;
@property (readwrite,assign,nonatomic) id <WCJumpInDataSource> dataSource;
@end

@implementation WCJumpInWindowController

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
}

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
	
	NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
	
	if (result == NSOKButton) {
		WCJumpInMatch *match = [[[self arrayController] selectedObjects] lastObject];
		
		[[[self dataSource] jumpInTextView] setSelectedRange:[[match item] jumpInRange]];
		[[[self dataSource] jumpInTextView] scrollRangeToVisible:[[[self dataSource] jumpInTextView] selectedRange]];
	}
	
	[self setSearchString:nil];
	[[self mutableMatches] removeAllObjects];
	[self setDataSource:nil];
}

- (IBAction)jump:(id)sender; {
	[[self window] close];
	[[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
}
- (IBAction)cancel:(id)sender; {
	[[self window] close];
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
}

- (IBAction)search:(id)sender; {
	if (![[self searchString] length]) {
		[[self mutableMatches] removeAllObjects];
		return;
	}
	
	[_operationQueue cancelAllOperations];
	[_operationQueue addOperation:[[[WCJumpInSearchOperation alloc] initWithJumpInWindowController:self] autorelease]];
}

@synthesize searchString=_searchString;
@synthesize matches=_matches;
@dynamic mutableMatches;
- (NSMutableArray *)mutableMatches {
	return [self mutableArrayValueForKey:@"matches"];
}
- (NSUInteger)countOfMatches {
	return [_matches count];
}
- (id)objectInMatchesAtIndex:(NSUInteger)index {
	return [_matches objectAtIndex:index];
}
- (void)insertObject:(WCJumpInMatch *)object inMatchesAtIndex:(NSUInteger)index {
	[_matches insertObject:object atIndex:index];
}
- (void)insertMatches:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_matches insertObjects:array atIndexes:indexes];
}
- (void)removeObjectFromMatchesAtIndex:(NSUInteger)index {
	[_matches removeObjectAtIndex:index];
}
- (void)removeMatchesAtIndexes:(NSIndexSet *)indexes {
	[_matches removeObjectsAtIndexes:indexes];
}
- (void)replaceObjectInMatchesAtIndex:(NSUInteger)index withObject:(WCJumpInMatch *)object {
	[_matches replaceObjectAtIndex:index withObject:object];
}
- (void)replaceMatchesAtIndexes:(NSIndexSet *)indexes withMatches:(NSArray *)array {
	[_matches replaceObjectsAtIndexes:indexes withObjects:array];
}
@dynamic dataSource;
- (id<WCJumpInDataSource>)dataSource {
	return _dataSource;
}
- (void)setDataSource:(id<WCJumpInDataSource>)dataSource {
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

@end
