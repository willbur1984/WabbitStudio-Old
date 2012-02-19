//
//  WCBreakpointNavigatorViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointNavigatorViewController.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "RSOutlineView.h"
#import "NSTreeController+RSExtensions.h"
#import "WCBreakpointContainer.h"
#import "WCBreakpointFileContainer.h"
#import "WCFileBreakpoint.h"
#import "WCProjectContainer.h"
#import "WCBreakpointManager.h"
#import "RSDefines.h"
#import "WCSourceFileSeparateWindowController.h"
#import "WCSourceTextViewController.h"
#import "WCProjectWindowController.h"
#import "WCTabViewController.h"

@interface WCBreakpointNavigatorViewController ()
@property (readwrite,retain,nonatomic) WCBreakpointFileContainer *filteredBreakpointFileContainer;

- (void)_updateBreakpoints;
@end

@implementation WCBreakpointNavigatorViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_projectDocument = nil;
	[_breakpointFileContainer release];
	[_filteredBreakpointFileContainer release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCBreakpointNavigatorView";
}

- (void)loadView {
	[super loadView];
	
	[[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"Filter Breakpoints", @"Filter Breakpoints")];
	[[[[self searchField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self searchField] cell] searchButtonCell] setAlternateImage:nil];
	
	[[self outlineView] setTarget:self];
	[[self outlineView] setDoubleAction:@selector(_outlineViewDoubleClick:)];
	[[self outlineView] setAction:@selector(_outlineViewSingleClick:)];
	
	[self _updateBreakpoints];
}
#pragma mark NSOutlineViewDelegate
static NSString *const kProjectCellIdentifier = @"ProjectCell";
static NSString *const kMainCellIdentifier = @"MainCell";

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	id object = [[item representedObject] representedObject];
	
	if ([object isKindOfClass:[WCFile class]])
		return [outlineView makeViewWithIdentifier:kProjectCellIdentifier owner:self];
	return [outlineView makeViewWithIdentifier:kMainCellIdentifier owner:self];
}

static const CGFloat kProjectCellHeight = 30.0;
static const CGFloat kMainCellHeight = 20.0;
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
	id object = [[item representedObject] representedObject];
	
	if ([object isKindOfClass:[WCFile class]])
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
#pragma mark WCNavigatorModule
- (NSArray *)selectedObjects {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	NSInteger clickedRow = [[self outlineView] clickedRow];
	if (clickedRow == -1 || [[[self outlineView] selectedRowIndexes] containsIndex:clickedRow])
		[retval addObjectsFromArray:[[self treeController] selectedRepresentedObjects]];
	else
		[retval addObject:[[[self outlineView] itemAtRow:clickedRow] representedObject]];
	
	return [[retval copy] autorelease];
}
- (void)setSelectedObjects:(NSArray *)objects {
	[[self treeController] setSelectedRepresentedObjects:objects];
}

- (NSArray *)selectedModelObjects {
	return [[self selectedObjects] valueForKey:@"representedObject"];
}
- (void)setSelectedModelObjects:(NSArray *)modelObjects {
	[[self treeController] setSelectedModelObjects:modelObjects];
}

- (NSArray *)selectedObjectsAndClickedObject:(id *)clickedObject; {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	
	if (clickedRow != -1 && clickedObject)
		*clickedObject = [[[self outlineView] itemAtRow:clickedRow] representedObject];
	
	return [self selectedObjects];
}

- (NSArray *)selectedModelObjectsAndClickedObject:(id *)clickedObject; {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	
	if (clickedRow != -1 && clickedObject)
		*clickedObject = [[[[self outlineView] itemAtRow:clickedRow] representedObject] representedObject];
	
	return [self selectedModelObjects];
}

- (NSResponder *)initialFirstResponder; {
	return [self outlineView];
}
#pragma mark *** Public Methods ***
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectDocument = projectDocument;
	_breakpointFileContainer = [[WCBreakpointFileContainer alloc] initWithFile:[[projectDocument projectContainer] representedObject]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidAddFileBreakpoint:) name:WCBreakpointManagerDidAddFileBreakpointNotification object:[projectDocument breakpointManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidRemoveFileBreakpoint:) name:WCBreakpointManagerDidRemoveFileBreakpointNotification object:[projectDocument breakpointManager]];
	
	return self;
}
#pragma mark IBActions

#pragma mark Properties
@synthesize treeController=_treeController;
@synthesize outlineView=_outlineView;
@synthesize searchField=_searchField;

@synthesize projectDocument=_projectDocument;
@synthesize breakpointFileContainer=_breakpointFileContainer;
@synthesize filteredBreakpointFileContainer=_filteredBreakpointFileContainer;
#pragma mark *** Private Methods ***
- (void)_updateBreakpoints; {
	[[[self breakpointFileContainer] mutableChildNodes] removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[[self breakpointFileContainer] childNodes] count])]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:nil];
	
	[[self breakpointFileContainer] willChangeValueForKey:@"statusString"];
	
	for (WCFile *file in [[[self projectDocument] breakpointManager] filesWithFileBreakpointsSortedByName]) {
		WCBreakpointFileContainer *fileContainer = [WCBreakpointFileContainer breakpointFileContainerWithFile:file];
		
		for (WCFileBreakpoint *fileBreakpoint in [[[[self projectDocument] breakpointManager] filesToFileBreakpointsSortedByLocation] objectForKey:file]) {
			WCBreakpointContainer *breakpointContainer = [WCBreakpointContainer breakpointContainerWithFileBreakpoint:fileBreakpoint];
			
			[[fileContainer mutableChildNodes] addObject:breakpointContainer];
		}
		
		[[[self breakpointFileContainer] mutableChildNodes] addObject:fileContainer];
	}
	
	[[self breakpointFileContainer] didChangeValueForKey:@"statusString"];
	
	[[self outlineView] expandItem:nil expandChildren:YES];
}
#pragma mark IBActions
- (IBAction)_outlineViewSingleClick:(id)sender {
	for (id container in [self selectedObjects]) {
		id result = [container representedObject];
		
		if (![result isKindOfClass:[WCFileBreakpoint class]])
			continue;
		
		WCFile *file = [[container parentNode] representedObject];
		WCSourceTextViewController *stvController = [[self projectDocument] openTabForFile:file tabViewContext:nil];
		
		[[stvController textView] setSelectedRange:[result range]];
		[[stvController textView] centerSelectionInVisibleArea:nil];
	}
	
}
- (IBAction)_outlineViewDoubleClick:(id)sender {
	for (id container in [self selectedObjects]) {
		id result = [container representedObject];
		
		if (![result isKindOfClass:[WCFileBreakpoint class]])
			continue;
		
		WCFile *file = [[container parentNode] representedObject];
		WCSourceFileSeparateWindowController *windowController = [[self projectDocument] openSeparateEditorForFile:file];
		WCSourceTextViewController *stvController = [[[[[windowController tabViewController] sourceFileDocumentsToSourceTextViewControllers] objectEnumerator] allObjects] lastObject];
		
		[[stvController textView] setSelectedRange:[result range]];
		[[stvController textView] centerSelectionInVisibleArea:nil];
	}
}
#pragma mark Notifications
- (void)_breakpointManagerDidAddFileBreakpoint:(NSNotification *)note {
	WCFileBreakpoint *newFileBreakpoint = [[note userInfo] objectForKey:WCBreakpointManagerDidAddFileBreakpointNewFileBreakpointUserInfoKey];
	WCBreakpointFileContainer *parentFileContainer = nil;
	
	for (WCBreakpointFileContainer *fileContainer in [[self breakpointFileContainer] childNodes]) {
		if ([newFileBreakpoint file] == [fileContainer representedObject]) {
			parentFileContainer = fileContainer;
			break;
		}
	}
	
	if (!parentFileContainer) {
		parentFileContainer = [WCBreakpointFileContainer breakpointFileContainerWithFile:[newFileBreakpoint file]];
		
		NSUInteger insertIndex = [[[self breakpointFileContainer] childNodes] indexOfObject:parentFileContainer inSortedRange:NSMakeRange(0, [[[self breakpointFileContainer] childNodes] count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(WCBreakpointFileContainer *obj1, WCBreakpointFileContainer *obj2) {
			return [[[obj1 representedObject] fileName] localizedStandardCompare:[[obj2 representedObject] fileName]];
		}];
		
		[[[self breakpointFileContainer] mutableChildNodes] insertObject:parentFileContainer atIndex:insertIndex];
		
		[[self outlineView] expandItem:[[self treeController] treeNodeForRepresentedObject:parentFileContainer]];
	}
	
	WCBreakpointContainer *breakpointContainer = [WCBreakpointContainer breakpointContainerWithFileBreakpoint:newFileBreakpoint];
	NSUInteger insertIndex = [[parentFileContainer childNodes] indexOfObject:breakpointContainer inSortedRange:NSMakeRange(0, [[parentFileContainer childNodes] count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(WCBreakpointContainer *obj1, WCBreakpointContainer *obj2) {
		NSRange range1 = [[obj1 representedObject] range];
		NSRange range2 = [[obj2 representedObject] range];
		
		if (range1.location < range2.location)
			return NSOrderedAscending;
		else if (range1.location > range2.location)
			return NSOrderedDescending;
		return NSOrderedSame;
	}];
	
	[[self breakpointFileContainer] willChangeValueForKey:@"statusString"];
	[parentFileContainer willChangeValueForKey:@"statusString"];
	[[parentFileContainer mutableChildNodes] insertObject:breakpointContainer atIndex:insertIndex];
	[parentFileContainer didChangeValueForKey:@"statusString"];
	[[self breakpointFileContainer] didChangeValueForKey:@"statusString"];
}
- (void)_breakpointManagerDidRemoveFileBreakpoint:(NSNotification *)note {
	WCFileBreakpoint *oldFileBreakpoint = [[note userInfo] objectForKey:WCBreakpointManagerDidRemoveFileBreakpointOldFileBreakpointUserInfoKey];
	WCBreakpointFileContainer *parentFileContainer = nil;
	
	for (WCBreakpointFileContainer *fileContainer in [[self breakpointFileContainer] childNodes]) {
		if ([oldFileBreakpoint file] == [fileContainer representedObject]) {
			parentFileContainer = fileContainer;
			break;
		}
	}
	
    NSAssert(parentFileContainer, @"parentFileContainer cannot be nil!");
	
	WCBreakpointContainer *oldBreakpointContainer = nil;
	
	for (WCBreakpointContainer *breakpointContainer in [parentFileContainer childNodes]) {
		if (oldFileBreakpoint == [breakpointContainer representedObject]) {
			oldBreakpointContainer = breakpointContainer;
			break;
		}
	}
	
	NSAssert(oldBreakpointContainer, @"oldBreakpointContainer cannot be nil!");
	
	[[self breakpointFileContainer] willChangeValueForKey:@"statusString"];
	[parentFileContainer willChangeValueForKey:@"statusString"];
	
	[[parentFileContainer mutableChildNodes] removeObjectIdenticalTo:oldBreakpointContainer];
	
	[parentFileContainer didChangeValueForKey:@"statusString"];
	[[self breakpointFileContainer] didChangeValueForKey:@"statusString"];
	
	if (![[parentFileContainer childNodes] count])
		[[[self breakpointFileContainer] mutableChildNodes] removeObjectIdenticalTo:parentFileContainer];
}
@end
