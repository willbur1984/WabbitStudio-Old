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
#import "WCAlertsViewController.h"
#import "NSAlert-OAExtensions.h"
#import "WCBreakpointNavigatorFileBreakpointOutlineCellView.h"
#import "WCEditBreakpointViewController.h"

@interface WCBreakpointNavigatorViewController ()
@property (readwrite,retain,nonatomic) WCBreakpointFileContainer *filteredBreakpointFileContainer;
@property (readonly,nonatomic) WCEditBreakpointViewController *editBreakpointViewController;

- (void)_updateBreakpoints;
@end

@implementation WCBreakpointNavigatorViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_editBreakpointViewController release];
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
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(editBreakpoint:)) {
		NSArray *selectedObjects = [self selectedObjects];
		
		if ([selectedObjects count] != 1)
			return NO;
		else if (![[[selectedObjects lastObject] representedObject] isKindOfClass:[WCBreakpoint class]])
			return NO;
	}
	else if ([menuItem action] == @selector(toggleBreakpoint:)) {
		NSArray *selectedObjects = [self selectedObjects];
		
		if (![selectedObjects count])
			return NO;
		
		NSArray *selectedBreakpointContainers = [selectedObjects valueForKeyPath:@"@unionOfArrays.descendantLeafNodes"];
		
		for (WCBreakpointContainer *breakpointContainer in selectedBreakpointContainers) {
			if ([[breakpointContainer representedObject] isActive]) {
				if ([selectedBreakpointContainers count] == 1)
					[menuItem setTitle:NSLocalizedString(@"Disable Breakpoint", @"Disable Breakpoint")];
				else
					[menuItem setTitle:NSLocalizedString(@"Disable Breakpoints", @"Disable Breakpoints")];
				
				return YES;
			}
		}
		
		if ([selectedBreakpointContainers count] == 1)
			[menuItem setTitle:NSLocalizedString(@"Enable Breakpoint", @"Enable Breakpoint")];
		else
			[menuItem setTitle:NSLocalizedString(@"Enable Breakpoints", @"Enable Breakpoints")];
	}
	else if ([menuItem action] == @selector(deleteBreakpoint:)) {
		NSArray *selectedObjects = [self selectedObjects];
		
		if (![selectedObjects count])
			return NO;
		
		NSArray *selectedBreakpointContainers = [selectedObjects valueForKeyPath:@"@unionOfArrays.descendantLeafNodes"];
		
		if ([selectedBreakpointContainers count] == 1) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBreakpointsKey])
				[menuItem setTitle:NSLocalizedString(@"Delete Breakpoint\u2026", @"Delete Breakpoint with ellipsis")];
			else
				[menuItem setTitle:NSLocalizedString(@"Delete Breakpoint", @"Delete Breakpoint")];
		}
		else {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBreakpointsKey])
				[menuItem setTitle:NSLocalizedString(@"Delete Breakpoints\u2026", @"Delete Breakpoints with ellipsis")];
			else
				[menuItem setTitle:NSLocalizedString(@"Delete Breakpoints", @"Delete Breakpoints")];
		}
	}
	return YES;
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
- (IBAction)editBreakpoint:(id)sender; {
	WCBreakpointContainer *breakpointContainer = [[self selectedObjects] lastObject];
	NSTreeNode *breakpointContainerNode = [[self treeController] treeNodeForRepresentedObject:breakpointContainer];
	WCBreakpointNavigatorFileBreakpointOutlineCellView *cellView = [[self outlineView] viewAtColumn:[[self outlineView] columnWithIdentifier:[[[self outlineView] outlineTableColumn] identifier]] row:[[self outlineView] rowForItem:breakpointContainerNode] makeIfNecessary:NO];
	WCEditBreakpointViewController *editBreakpointViewController = [self editBreakpointViewController];
	NSRect breakpointButtonBounds = [cellView convertRect:[[cellView breakpointButton] bounds] fromView:[cellView breakpointButton]];
	
	breakpointButtonBounds.origin.y -= 4.0;
	
	[editBreakpointViewController setBreakpoint:[breakpointContainer representedObject]];
	[editBreakpointViewController showEditBreakpointViewRelativeToRect:breakpointButtonBounds ofView:cellView preferredEdge:NSMinYEdge];
}
- (IBAction)toggleBreakpoint:(id)sender; {
	NSArray *selectedBreakpointContainers = [[self selectedObjects] valueForKeyPath:@"@unionOfArrays.descendantLeafNodes"];
	
	for (WCBreakpointContainer *breakpointContainer in selectedBreakpointContainers) {
		WCBreakpoint *breakpoint = [breakpointContainer representedObject];
		
		[breakpoint setActive:(![breakpoint isActive])];
	}
}
- (IBAction)deleteBreakpoint:(id)sender; {
	NSArray *selectedBreakpointContainers = [[self selectedObjects] valueForKeyPath:@"@unionOfArrays.descendantLeafNodes"];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBreakpointsKey]) {
		NSString *message;
		NSString *informative;
		if ([selectedBreakpointContainers count] == 1) {
			message = NSLocalizedString(@"Delete Breakpoint?", @"Delete Breakpoint?");
			informative = NSLocalizedString(@"Are you sure you want to delete the selected breakpoint? This operation cannot be undone.", @"Are you sure you want to delete the selected breakpoint? This operation cannot be undone.");
		}
		else {
			message = [NSString stringWithFormat:NSLocalizedString(@"Delete %lu Breakpoints?", @"delete multiple breakpoints format string"),[selectedBreakpointContainers count]];
			informative = NSLocalizedString(@"Are you sure you want to delete the selected breakpoints? This operation cannot be undone.", @"Are you sure you want to delete the selected breakpoints? This operation cannot be undone.");
		}
		
		NSAlert *deleteBreakpointAlert = [NSAlert alertWithMessageText:message defaultButton:LOCALIZED_STRING_DELETE alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:informative];
		
		[deleteBreakpointAlert setShowsSuppressionButton:YES];
		
		[[deleteBreakpointAlert suppressionButton] bind:NSValueBinding toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:WCAlertsWarnBeforeDeletingBreakpointsKey] options:[NSDictionary dictionaryWithObjectsAndKeys:NSNegateBooleanTransformerName,NSValueTransformerNameBindingOption, nil]];
		
		[deleteBreakpointAlert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert suppressionButton] unbind:NSValueBinding];
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			for (WCBreakpointContainer *breakpointContainer in selectedBreakpointContainers)
				[[[self projectDocument] breakpointManager] removeFileBreakpoint:[breakpointContainer representedObject]];
		}];
	}
	else {
		for (WCBreakpointContainer *breakpointContainer in selectedBreakpointContainers)
			[[[self projectDocument] breakpointManager] removeFileBreakpoint:[breakpointContainer representedObject]];
	}
}
#pragma mark Properties
@synthesize treeController=_treeController;
@synthesize outlineView=_outlineView;
@synthesize searchField=_searchField;

@synthesize projectDocument=_projectDocument;
@synthesize breakpointFileContainer=_breakpointFileContainer;
@synthesize filteredBreakpointFileContainer=_filteredBreakpointFileContainer;
@dynamic editBreakpointViewController;
- (WCEditBreakpointViewController *)editBreakpointViewController {
	if (!_editBreakpointViewController)
		_editBreakpointViewController = [[WCEditBreakpointViewController alloc] initWithBreakpoint:nil];
	return _editBreakpointViewController;
}
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
		[[stvController textView] scrollRangeToVisible:[result range]];
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
		[[stvController textView] scrollRangeToVisible:[result range]];
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
