//
//  WCSearchNavigatorViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSearchNavigatorViewController.h"
#import "NSTreeController+RSExtensions.h"
#import "WCProjectContainer.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "WCSearchContainer.h"
#import "RSFindOptionsViewController.h"
#import "WCSearchOperation.h"
#import "WCSearchResult.h"
#import "WCSourceTextViewController.h"
#import "WCSourceTextView.h"
#import "WCSourceFileSeparateWindowController.h"
#import "WCTabViewController.h"
#import "RSOutlineView.h"

@interface WCSearchNavigatorViewController ()
@property (readonly,nonatomic) RSFindOptionsViewController *filterOptionsViewController;
@property (readwrite,retain,nonatomic) NSRegularExpression *searchRegularExpression;

@end

@implementation WCSearchNavigatorViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_searchRegularExpression release];
	[_operationQueue release];
	[_searchOptionsViewController release];
	[_filterOptionsViewController release];
	[_statusString release];
	[_searchString release];
	[_filterString release];
	[_filteredSearchContainer release];
	[_searchContainer release];
	[_projectContainer release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCSearchNavigatorView";
}

- (void)loadView {
	[super loadView];
	
	[[[self filterField] cell] setPlaceholderString:NSLocalizedString(@"Filter Search Results", @"Filter Search Results")];
	[[[[self filterField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self filterField] cell] searchButtonCell] setAlternateImage:nil];
	
	[[self outlineView] setTarget:self];
	[[self outlineView] setDoubleAction:@selector(_outlineViewDoubleClick:)];
	[[self outlineView] setAction:@selector(_outlineViewSingleClick:)];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(toggleFilterOptions:)) {
		if ([[self filterOptionsViewController] areFindOptionsVisible])
			[menuItem setTitle:NSLocalizedString(@"Hide Filter Options\u2026", @"Hide Filter Options with ellipsis")];
		else
			[menuItem setTitle:NSLocalizedString(@"Show Filter Options\u2026", @"Show Filter Options with ellipsis")];
	}
	else if ([menuItem action] == @selector(toggleSearchOptions:)) {
		if ([[self searchOptionsViewController] areFindOptionsVisible])
			[menuItem setTitle:NSLocalizedString(@"Hide Search Options\u2026", @"Hide Search Options with ellipsis")];
		else
			[menuItem setTitle:NSLocalizedString(@"Show Search Options\u2026", @"Show Search Options with ellipsis")];
	}
	return YES;
}

#pragma mark NSOutlineViewDelegate
static NSString *const kProjectCellIdentifier = @"ProjectCell";
static NSString *const kMainCellIdentifier = @"MainCell";
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	id file = [[item representedObject] representedObject];
	
	if ([file isKindOfClass:[WCFile class]])
		return [outlineView makeViewWithIdentifier:kProjectCellIdentifier owner:self];
	return [outlineView makeViewWithIdentifier:kMainCellIdentifier owner:self];
}

static const CGFloat kProjectCellHeight = 30.0;
static const CGFloat kMainCellHeight = 20.0;
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
	id file = [[item representedObject] representedObject];
	
	if ([file isKindOfClass:[WCFile class]])
		return kProjectCellHeight;
	return kMainCellHeight;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	if ([rowView respondsToSelector:@selector(setOutlineView:)])
		[(id)rowView setOutlineView:outlineView];
}
- (void)outlineView:(NSOutlineView *)outlineView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	if ([rowView respondsToSelector:@selector(setOutlineView:)])
		[(id)rowView setOutlineView:nil];
}

#pragma mark RSOutlineViewDelegate
- (void)handleReturnPressedForOutlineView:(RSOutlineView *)outlineView {
	[[self outlineView] sendAction:[[self outlineView] action] to:[[self outlineView] target]];
}
#pragma mark RSFindOptionsViewControllerDelegate
- (void)findOptionsViewControllerDidChangeFindOptions:(RSFindOptionsViewController *)viewController {
	if (viewController == [self filterOptionsViewController]) {
		// TODO: update the filter results
	}
}

#pragma mark WCNavigatorModule
- (NSArray *)selectedObjects {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	NSMutableArray *retval = [NSMutableArray array];
	if (clickedRow == -1 || [[[self outlineView] selectedRowIndexes] containsIndex:clickedRow]) {
		[retval addObjectsFromArray:[[self treeController] selectedRepresentedObjects]];
	}
	else {
		id clickedFile = [[[self outlineView] itemAtRow:clickedRow] representedObject];
		
		[retval addObject:clickedFile];
	}
	return retval;
}
- (void)setSelectedObjects:(NSArray *)objects {
	[[self treeController] setSelectedRepresentedObjects:objects];
}
- (NSArray *)selectedModelObjects; {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[[[self outlineView] selectedRowIndexes] count]];
	
	if (clickedRow == -1 || [[[self outlineView] selectedRowIndexes] containsIndex:clickedRow]) {
		[retval addObjectsFromArray:[[self treeController] selectedModelObjects]];
	}
	else {
		id clickedModelObject = [[[[self outlineView] itemAtRow:clickedRow] representedObject] representedObject];
		
		[retval addObject:clickedModelObject];
	}
	
	return [[retval copy] autorelease];
}
- (void)setSelectedModelObjects:(NSArray *)modelObjects; {
	[[self treeController] setSelectedModelObjects:modelObjects];
}
#pragma mark *** Public Methods ***
- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectContainer = [projectContainer retain];
	_searchContainer = [[WCSearchContainer alloc] initWithFile:[_projectContainer project]];
	_operationQueue = [[NSOperationQueue alloc] init];
	[_operationQueue setMaxConcurrentOperationCount:1];
	
	return self;
}
#pragma mark IBActions
- (IBAction)filter:(id)sender; {
	
}
- (IBAction)search:(id)sender; {
	if (![[self searchString] length]) {
		NSBeep();
		return;
	}
	else if ([[self searchOptionsViewController] findStyle] == RSFindOptionsFindStyleRegularExpression) {
		NSRegularExpressionOptions regexOptions = 0;
		if (![[self searchOptionsViewController] matchCase])
			regexOptions |= NSRegularExpressionCaseInsensitive;
		if ([[self searchOptionsViewController] anchorsMatchLines])
			regexOptions |= NSRegularExpressionAnchorsMatchLines;
		if ([[self searchOptionsViewController] dotMatchesNewlines])
			regexOptions |= NSRegularExpressionDotMatchesLineSeparators;
		
		NSError *outError;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[self searchString] options:regexOptions error:&outError];
		
		if (!regex) {
			[[NSApplication sharedApplication] presentError:outError];
			return;
		}
		
		[self setSearchRegularExpression:regex];
	}
	
	[[[self searchContainer] mutableChildNodes] removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[[self searchContainer] childNodes] count])]];
	
	[_operationQueue cancelAllOperations];
	[_operationQueue addOperation:[[[WCSearchOperation alloc] initWithSearchNavigatorViewController:self] autorelease]];
}

- (IBAction)toggleSearchOptions:(id)sender; {
	if ([[self searchOptionsViewController] areFindOptionsVisible])
		[self hideSearchOptions:nil];
	else
		[self showSearchOptions:nil];
}
- (IBAction)showSearchOptions:(id)sender; {
	NSRect rect = [(NSSearchFieldCell *)[[self searchField] cell] searchButtonRectForBounds:[[self searchField] bounds]];
	[[self searchOptionsViewController] showFindOptionsViewRelativeToRect:rect ofView:[self searchField] preferredEdge:NSMaxYEdge];
}
- (IBAction)hideSearchOptions:(id)sender; {
	[[self searchOptionsViewController] hideFindOptionsView];
}

- (IBAction)toggleFilterOptions:(id)sender; {
	if ([[self filterOptionsViewController] areFindOptionsVisible])
		[self hideFilterOptions:nil];
	else
		[self showFilterOptions:nil];
}
- (IBAction)showFilterOptions:(id)sender; {
	NSRect rect = [(NSSearchFieldCell *)[[self filterField] cell] searchButtonRectForBounds:[[self filterField] bounds]];
	[[self filterOptionsViewController] showFindOptionsViewRelativeToRect:rect ofView:[self filterField] preferredEdge:NSMinYEdge];
}
- (IBAction)hideFilterOptions:(id)sender; {
	[[self filterOptionsViewController] hideFindOptionsView];
}
#pragma mark Properties
@synthesize outlineView=_outlineView;
@synthesize treeController=_treeController;
@synthesize searchField=_searchField;
@synthesize filterField=_filterField;

@synthesize searchContainer=_searchContainer;
@synthesize filteredSearchContainer=_filteredSearchContainer;
@synthesize filterString=_filterString;
@synthesize searchString=_searchString;
@dynamic filterOptionsViewController;
- (RSFindOptionsViewController *)filterOptionsViewController {
	if (!_filterOptionsViewController) {
		_filterOptionsViewController = [[RSFindOptionsViewController alloc] init];
		[_filterOptionsViewController setRegexOptionsEnabled:NO];
		[_filterOptionsViewController setWrapAround:NO];
		[_filterOptionsViewController setWrapAroundEnabled:NO];
		[_filterOptionsViewController setDelegate:self];
	}
	return _filterOptionsViewController;
}
@dynamic searchOptionsViewController;
- (RSFindOptionsViewController *)searchOptionsViewController {
	if (!_searchOptionsViewController) {
		_searchOptionsViewController = [[RSFindOptionsViewController alloc] init];
		[_searchOptionsViewController setWrapAround:NO];
		[_searchOptionsViewController setWrapAroundEnabled:NO];
		[_searchOptionsViewController setDelegate:self];
	}
	return _searchOptionsViewController;
}
@synthesize statusString=_statusString;
@synthesize searchScope=_searchScope;
@synthesize viewMode=_viewMode;
@dynamic searching;
- (BOOL)isSearching {
	return _searchNavigatorFlags.searching;
}
- (void)setSearching:(BOOL)searching {
	_searchNavigatorFlags.searching = searching;
}
@dynamic projectDocument;
- (WCProjectDocument *)projectDocument {
	return [[[self projectContainer] project] document];
}
@synthesize projectContainer=_projectContainer;
@synthesize searchRegularExpression=_searchRegularExpression;

- (IBAction)_outlineViewDoubleClick:(id)sender; {
	for (id container in [self selectedObjects]) {
		id result = [container representedObject];
		
		if (![result isKindOfClass:[WCSearchResult class]])
			continue;
		
		WCFile *file = [[container parentNode] representedObject];
		WCSourceFileSeparateWindowController *windowController = [[self projectDocument] openSeparateEditorForFile:file];
		WCSourceTextViewController *stvController = [[[[[windowController tabViewController] sourceFileDocumentsToSourceTextViewControllers] objectEnumerator] allObjects] lastObject];
		
		[[stvController textView] setSelectedRange:[result range]];
		[[stvController textView] scrollRangeToVisible:[result range]];
	}
}
- (IBAction)_outlineViewSingleClick:(id)sender; {
	for (id container in [self selectedObjects]) {
		id result = [container representedObject];
		
		if (![result isKindOfClass:[WCSearchResult class]])
			continue;
		
		WCFile *file = [[container parentNode] representedObject];
		WCSourceTextViewController *stvController = [[self projectDocument] openTabForFile:file tabViewContext:nil];
		
		[[stvController textView] setSelectedRange:[result range]];
		[[stvController textView] scrollRangeToVisible:[result range]];
	}
}

@end
