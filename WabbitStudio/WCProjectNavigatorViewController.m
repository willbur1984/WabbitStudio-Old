//
//  WCProjectNavigatorViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectNavigatorViewController.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "WCProjectContainer.h"
#import "RSOutlineView.h"
#import "RSFindOptionsViewController.h"
#import "RSDefines.h"
#import "NSTreeController+RSExtensions.h"
#import "RSNavigatorControl.h"
#import "WCProjectWindowController.h"
#import "WCTabViewController.h"
#import "WCDocumentController.h"
#import "NSArray+WCExtensions.h"
#import "NSURL+RSExtensions.h"
#import "NSAlert-OAExtensions.h"
#import "NSOutlineView+RSExtensions.h"

NSString *const WCProjectNavigatorDidAddNewGroupNotification = @"WCProjectNavigatorDidAddNewGroupNotification";
NSString *const WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey = @"WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey";

NSString *const WCProjectNavigatorDidGroupNodesNotification = @"WCProjectNavigatorDidGroupNodesNotification";
NSString *const WCProjectNavigatorDidGroupNodesNotificationGroupedNodesUserInfoKey = @"WCProjectNavigatorDidGroupNodesNotificationGroupedNodesUserInfoKey";

NSString *const WCProjectNavigatorDidRemoveNodesNotification = @"WCProjectNavigatorDidRemoveNodesNotification";
NSString *const WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey = @"WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey";

NSString *const WCProjectNavigatorDidUngroupNodesNotification = @"WCProjectNavigatorDidUngroupNodesNotification";
NSString *const WCProjectNavigatorDidUngroupNodesNotificationUngroupedNodesUserInfoKey = @"WCProjectNavigatorDidUngroupNodesNotificationUngroupedNodesUserInfoKey";

NSString *const WCProjectNavigatorDidRenameNodeNotification = @"WCProjectNavigatorDidRenameNodeNotification";
NSString *const WCProjectNavigatorDidRenameNodeNotificationRenamedNodeUserInfoKey = @"WCProjectNavigatorDidRenameNodeNotificationRenamedNodeUserInfoKey";

@interface WCProjectNavigatorViewController ()
@property (readwrite,retain,nonatomic) WCProjectContainer *filteredProjectContainer;
@property (readwrite,assign,nonatomic) BOOL switchTreeControllerContentBinding;
@property (readonly,nonatomic) RSFindOptionsViewController *filterOptionsViewController;

- (BOOL)_deleteRequiresUserConfirmation:(BOOL *)projectContainerIsSelected;
@end

@implementation WCProjectNavigatorViewController
- (void)dealloc {
	//for (WCFileContainer *fileContainer in [_projectContainer descendantNodes])
	//	[[fileContainer representedObject] removeObserver:self forKeyPath:@"fileName" context:self];
	[_filterOptionsViewController release];
	[_filterString release];
	[_filteredProjectContainer release];
	[_projectContainer release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCProjectNavigatorView";
}

- (void)loadView {
	[super loadView];
	
	[[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"Filter Files", @"Filter Files")];
	[[[[self searchField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self searchField] cell] searchButtonCell] setAlternateImage:nil];
	
	[[self outlineView] setTarget:self];
	[[self outlineView] setDoubleAction:@selector(_outlineViewDoubleClick:)];
	
	NSDictionary *settings = [[[[[self projectContainer] project] document] projectSettings] objectForKey:[self projectDocumentSettingsKey]];
	
	if ([[settings objectForKey:@"expandedItems"] count]) {
		NSMutableArray *itemsToExpand = [NSMutableArray arrayWithCapacity:0];
		
		for (NSString *UUID in [settings objectForKey:@"expandedItems"]) {
			NSLogObject(UUID);
			
			WCFile *file = [[[[[self projectContainer] project] document] UUIDsToObjects] objectForKey:UUID];
			WCFileContainer *fileContainer = [[[[self projectContainer] project] document] fileContainerForFile:file];
			
			if (fileContainer)
				[itemsToExpand addObject:fileContainer];
		}
		
		if ([itemsToExpand count]) {
			[itemsToExpand insertObject:[self projectContainer] atIndex:0];
			[[self outlineView] expandItems:itemsToExpand];
		}
		else
			[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
	}
	else
		[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(toggleFilterOptions:)) {
		if ([[self filterOptionsViewController] areFindOptionsVisible])
			[menuItem setTitle:NSLocalizedString(@"Hide Filter Options\u2026", @"hide filter options with ellipsis")];
		else
			[menuItem setTitle:NSLocalizedString(@"Show Filter Options\u2026", @"show filter options with ellipsis")];
	}
	else if ([menuItem action] == @selector(showInFinder:)) {
		for (WCFileContainer *fileContainer in [self selectedObjects]) {
			if ([fileContainer isLeafNode])
				return YES;
		}
		return NO;
	}
	else if ([menuItem action] == @selector(openWithExternalEditor:)) {
		for (WCFileContainer *fileContainer in [self selectedObjects]) {
			if ([fileContainer isLeafNode] && ![[fileContainer representedObject] isSourceFile])
				return YES;
		}
		return NO;
	}
	else if ([menuItem action] == @selector(newGroupFromSelection:)) {
		for (id container in [self selectedObjects]) {
			if ([container isKindOfClass:[WCProjectContainer class]])
				return NO;
		}
		return YES;
	}
	else if ([menuItem action] == @selector(ungroupSelection:)) {
		for (id container in [self selectedObjects]) {
			if ([container isLeafNode] || [container isKindOfClass:[WCProjectContainer class]])
				return NO;
		}
		return YES;
	}
	else if ([menuItem action] == @selector(rename:)) {
		for (id container in [self selectedObjects]) {
			if ([container isKindOfClass:[WCProjectContainer class]])
				return NO;
		}
		return YES;
	}
	else if ([menuItem action] == @selector(delete:)) {
		BOOL isProjectContainerSelected;
		BOOL deleteRequiresConfirmation = [self _deleteRequiresUserConfirmation:&isProjectContainerSelected];
		
		if (isProjectContainerSelected)
			return NO;
		
		if (deleteRequiresConfirmation)
			[menuItem setTitle:LOCALIZED_STRING_DELETE_WITH_ELLIPSIS];
		else
			[menuItem setTitle:LOCALIZED_STRING_DELETE];
	}
	else if ([menuItem action] == @selector(addFilesToProject:)) {
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Add Files to \"%@\"\u2026", @"add files to project format string"),[[[[self projectContainer] project] document] displayName]]];
	}
	return YES;
}

#pragma mark NSOutlineViewDelegate
static NSString *const kProjectCellIdentifier = @"ProjectCell";
static NSString *const kMainCellIdentifier = @"MainCell";
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	id file = [[item representedObject] representedObject];
	
	if ([file isKindOfClass:[WCProject class]])
		return [outlineView makeViewWithIdentifier:kProjectCellIdentifier owner:self];
	return [outlineView makeViewWithIdentifier:kMainCellIdentifier owner:self];
}

static const CGFloat kProjectCellHeight = 30.0;
static const CGFloat kMainCellHeight = 18.0;
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
	id file = [[item representedObject] representedObject];
	
	if ([file isKindOfClass:[WCProject class]])
		return kProjectCellHeight;
	return kMainCellHeight;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	if ([QLPreviewPanel sharedPreviewPanelExists] &&
		[[QLPreviewPanel sharedPreviewPanel] isVisible]) {
		
		[[QLPreviewPanel sharedPreviewPanel] reloadData];
	}
}
#pragma mark RSOutlineViewDelegate
- (void)handleSpacePressedForOutlineView:(RSOutlineView *)outlineView {
	if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
		[[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
	else
		[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
}
- (void)handleDeletePressedForOutlineView:(RSOutlineView *)outlineView {
	BOOL isProjectContainerSelected;
	BOOL deleteRequiresUserConfirmation = [self _deleteRequiresUserConfirmation:&isProjectContainerSelected];
	
	if (isProjectContainerSelected) {
		NSBeep();
		return;
	}
	else if (deleteRequiresUserConfirmation) {
		NSArray *fileContainersToDelete = [self selectedObjects];
		NSString *message = ([fileContainersToDelete count] == 1)?[NSString stringWithFormat:NSLocalizedString(@"Do you want to move \"%@\" to the trash, or only remove the reference to it?", @"project navigator delete message single file format string"),[[[fileContainersToDelete firstObject] representedObject] fileName]]:[NSString stringWithFormat:NSLocalizedString(@"Do you want to move %lu files to the trash, or only remove the references to them?", @"project navigator delete message multiple files format string"),[fileContainersToDelete count]];
		NSString *informative = NSLocalizedString(@"This operation cannot be undone. Unsaved changes will be lost.", @"This operation cannot be undone. Unsaved changes will be lost.");
		NSString *defaultButtonString = ([fileContainersToDelete count] == 1)?NSLocalizedString(@"Remove Reference Only", @"Remove Reference Only"):NSLocalizedString(@"Remove References Only", @"Remove References Only");
		NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:defaultButtonString alternateButton:LOCALIZED_STRING_CANCEL otherButton:NSLocalizedString(@"Move to Trash", @"Move to Trash") informativeTextWithFormat:informative];
		
		[alert setAlertStyle:NSCriticalAlertStyle];
		
		[alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			else if (returnCode == NSAlertDefaultReturn) {
				
			}
			else {
				
			}
		}];
	}
	else {
		NSArray *fileContainersToDelete = [self selectedObjects];
		
		for (WCFileContainer *fileContainer in fileContainersToDelete)
			[[[fileContainer parentNode] mutableChildNodes] removeObjectIdenticalTo:fileContainer];
		
		NSArray *allContainersThatWereDeleted = [fileContainersToDelete valueForKeyPath:@"@unionOfArrays.descendantNodesInclusive"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidRemoveNodesNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:allContainersThatWereDeleted,WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey, nil]];
	}
}
- (void)handleReturnPressedForOutlineView:(RSOutlineView *)outlineView {
	for (WCFileContainer *selectedNode in [self selectedObjects]) {
		if ([[selectedNode representedObject] isSourceFile])
			[[[[self projectContainer] project] document] openTabForFile:[selectedNode representedObject]];
	}
}
#pragma mark QLPreviewPanelDataSource
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel; {
	return [[self selectedObjects] count];
}
- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
	return [[self selectedObjects] objectAtIndex:index];
}
#pragma mark QLPreviewPanelDelegate
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item; {
	NSInteger row = [[self outlineView] rowForItem:[[self treeController] treeNodeForRepresentedObject:item]];
	
	if (!NSLocationInRange(row, [[self outlineView] rowsInRect:[[self outlineView] visibleRect]]))
		return NSZeroRect;
	else if (![[[[[[[self projectContainer] project] document] projectWindowController] navigatorControl] selectedItemIdentifier] isEqualToString:@"project"])
		return NSZeroRect;
	
	NSTableRowView *rowView = [[self outlineView] rowViewAtRow:row makeIfNecessary:NO];
	NSImageView *imageView = [(NSTableCellView *)[rowView viewAtColumn:0] imageView];
	NSRect rect = [imageView frame];
	rect = [imageView convertRectToBase:rect];
	rect.origin = [[[self view] window] convertBaseToScreen:rect.origin];
	return rect;
}

- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect; {
	NSInteger row = [[self outlineView] rowForItem:[[self treeController] treeNodeForRepresentedObject:item]];
	NSTableRowView *rowView = [[self outlineView] rowViewAtRow:row makeIfNecessary:NO];
	NSImageView *imageView = [(NSTableCellView *)[rowView viewAtColumn:0] imageView];
	
	return [imageView image];
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
#pragma mark WCProjectDocumentSettingsProvider
- (NSString *)projectDocumentSettingsKey {
	return @"projectNavigatorKey";
}
- (NSDictionary *)projectDocumentSettings {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[retval setObject:[[[self outlineView] expandedItems] valueForKeyPath:@"representedObject.UUID"] forKey:@"expandedItems"];
	
	return [[retval copy] autorelease];
}
#pragma mark RSFindOptionsViewControllerDelegate
- (void)findOptionsViewControllerDidChangeFindOptions:(RSFindOptionsViewController *)viewController {
	if ([[self filterString] length])
		[self filter:nil];
}

#pragma mark *** Public Methods ***
- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectContainer = [projectContainer retain];
	_projectNavigatorFlags.switchTreeControllerContentBinding = YES;
	
	[[[[projectContainer project] document] projectSettingsProviders] addObject:self];
	
	return self;
}

#pragma mark IBActions
- (IBAction)filter:(id)sender; {
	if (![[self filterString] length]) {
		[self setSwitchTreeControllerContentBinding:YES];
		[[self treeController] bind:NSContentObjectBinding toObject:self withKeyPath:@"projectContainer" options:nil];
		[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
		[self setFilteredProjectContainer:nil];
		return;
	}
	else if ([self switchTreeControllerContentBinding]) {
		[self setSwitchTreeControllerContentBinding:NO];
		[[self treeController] bind:NSContentObjectBinding toObject:self withKeyPath:@"filteredProjectContainer" options:nil];
	}
	
	WCProjectContainer *filteredProjectContainer = [WCProjectContainer projectContainerWithProject:[[self projectContainer] project]];
	NSArray *leafNodes = [[self projectContainer] descendantLeafNodes];
	NSMutableArray *filteredLeafNodes = [NSMutableArray arrayWithCapacity:[leafNodes count]];
	NSMapTable *parentNodesToFilteredParentNodes = [NSMapTable mapTableWithWeakToStrongObjects];
	NSPredicate *predicate;
	
	[parentNodesToFilteredParentNodes setObject:filteredProjectContainer forKey:[self projectContainer]];
	
	if ([[self filterOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual) {
		switch ([[self filterOptionsViewController] matchStyle]) {
			case RSFindOptionsMatchStyleContains:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName contains %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName contains[c] %@",[self filterString]];
				break;
			case RSFindOptionsMatchStyleStartsWith:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName beginswith %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName beginswith[c] %@",[self filterString]];
				break;
			case RSFindOptionsMatchStyleEndsWith:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName endswith %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName endswith[c] %@",[self filterString]];
				break;
			case RSFindOptionsMatchStyleWholeWord:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName like %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName like[c] %@",[self filterString]];
				break;
			default:
				break;
		}
	}
	else {
		if ([[self filterOptionsViewController] matchCase])
			predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName matches %@",[self filterString]];
		else
			predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName matches[c] %@",[self filterString]];
	}
	
	[filteredLeafNodes setArray:[leafNodes filteredArrayUsingPredicate:predicate]];
	
	for (WCFileContainer *leafNode in filteredLeafNodes) {
		WCFileContainer *filteredLeafNode = [WCFileContainer fileContainerWithFile:[leafNode representedObject]];
		
		while ([leafNode parentNode]) {
			WCFileContainer *filteredParentNode = [parentNodesToFilteredParentNodes objectForKey:[leafNode parentNode]];
			
			if (filteredParentNode) {
				[[filteredParentNode mutableChildNodes] addObject:filteredLeafNode];
				filteredLeafNode = nil;
				break;
			}
			
			filteredParentNode = [RSTreeNode treeNodeWithRepresentedObject:[[leafNode parentNode] representedObject]];
			[parentNodesToFilteredParentNodes setObject:filteredParentNode forKey:[leafNode parentNode]];
			[[filteredParentNode mutableChildNodes] addObject:filteredLeafNode];
			
			leafNode = [leafNode parentNode];
			filteredLeafNode = filteredParentNode;
		}
		
		if (filteredLeafNode)
			[[filteredProjectContainer mutableChildNodes] addObject:filteredLeafNode];
	}
	
	[self setFilteredProjectContainer:filteredProjectContainer];
	[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:YES];
}

- (IBAction)toggleFilterOptions:(id)sender; {
	if ([[self filterOptionsViewController] areFindOptionsVisible])
		[self hideFilterOptions:nil];
	else
		[self showFilterOptions:nil];
}
- (IBAction)showFilterOptions:(id)sender; {
	NSRect rect = [(NSSearchFieldCell *)[[self searchField] cell] searchButtonRectForBounds:[[self searchField] bounds]];
	[[self filterOptionsViewController] showFindOptionsViewRelativeToRect:rect ofView:[self searchField] preferredEdge:NSMaxYEdge];
}
- (IBAction)hideFilterOptions:(id)sender; {
	[[self filterOptionsViewController] hideFindOptionsView];
}

- (IBAction)addFilesToProject:(id)sender; {
	
}

- (IBAction)showInFinder:(id)sender; {
	NSMutableArray *URLsToShow = [NSMutableArray arrayWithCapacity:0];
	
	for (WCFileContainer *fileContainer in [self selectedObjects]) {
		if ([fileContainer isLeafNode])
			[URLsToShow addObject:[[fileContainer representedObject] fileURL]];
	}
	
	if ([URLsToShow count])
		[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:URLsToShow];
}
- (IBAction)openWithExternalEditor:(id)sender; {
	for (WCFileContainer *fileContainer in [self selectedObjects]) {
		if ([fileContainer isLeafNode] && ![[fileContainer representedObject] isSourceFile])
			[[NSWorkspace sharedWorkspace] openURL:[[fileContainer representedObject] fileURL]];
	}
}

- (IBAction)newGroup:(id)sender; {
	// grab the first selected node
	WCFileContainer *selectedFileContainer = [[self selectedObjects] firstObject];
	NSUInteger insertIndex = 0;
	
	// if the node is a leaf node, adjust the insertion index and node appropriately
	if ([selectedFileContainer isLeafNode]) {
		insertIndex = [[[selectedFileContainer parentNode] childNodes] indexOfObjectIdenticalTo:selectedFileContainer] + 1;
		selectedFileContainer = [selectedFileContainer parentNode];
	}
	
	// create the new group
	WCGroupContainer *groupContainer = [WCGroupContainer fileContainerWithFile:[WCGroup groupWithFileURL:[[selectedFileContainer representedObject] fileURL] name:NSLocalizedString(@"New Group", @"New Group")]];
	
	// insert the new group into the outline view
	[[selectedFileContainer mutableChildNodes] insertObject:groupContainer atIndex:insertIndex];
	
	// select the new group
	[self setSelectedObjects:[NSArray arrayWithObjects:groupContainer, nil]];
	
	// edit the new group
	[[self outlineView] editColumn:0 row:[[self outlineView] selectedRow] withEvent:nil select:YES];
	
	// post the appropriate notification
	[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidAddNewGroupNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:groupContainer,WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey, nil]];
	
	// let the document know there was a change
	[[[[self projectContainer] project] document] updateChangeCount:NSChangeDone];
}
- (IBAction)newGroupFromSelection:(id)sender; {
	// grab our selected nodes
	NSArray *selectedFileContainers = [self selectedObjects];
	// grab the first selected node
	WCFileContainer *firstFileContainer = [selectedFileContainers firstObject];
	// determine our insertion index
	NSUInteger insertIndex = [[[firstFileContainer parentNode] childNodes] indexOfObjectIdenticalTo:firstFileContainer] + 1;
	// determine our directory url for the new group
	NSURL *directoryURL = ([firstFileContainer isLeafNode])?[[firstFileContainer representedObject] parentDirectoryURL]:[[firstFileContainer representedObject] fileURL];
	// create our new group
	WCGroupContainer *groupContainer = [WCGroupContainer fileContainerWithFile:[WCGroup groupWithFileURL:directoryURL name:NSLocalizedString(@"New Group", @"New Group")]];
	
	// insert the new group into the outline view
	[[[firstFileContainer parentNode] mutableChildNodes] insertObject:groupContainer atIndex:insertIndex];
	
	// move the selected nodes to the new group
	[[self treeController] moveNodes:[[self treeController] treeNodesForRepresentedObjects:selectedFileContainers] toIndexPath:[[[[self treeController] treeNodeForRepresentedObject:groupContainer] indexPath] indexPathByAddingIndex:0]];
	
	// select the new group
	[self setSelectedObjects:[NSArray arrayWithObjects:groupContainer, nil]];
	
	// edit the new group
	[[self outlineView] editColumn:0 row:[[self outlineView] selectedRow] withEvent:nil select:YES];
	
	// the set of grouped nodes is the union of all the leaf nodes of the originally selected containers
	NSSet *groupedNodes = [NSSet setWithArray:[selectedFileContainers valueForKeyPath:@"@unionOfArrays.descendantLeafNodesInclusive"]];
	
	// post the appropriate notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidAddNewGroupNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:groupContainer,WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey, nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidGroupNodesNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:groupedNodes,WCProjectNavigatorDidGroupNodesNotificationGroupedNodesUserInfoKey, nil]];
	
	// let the document know there was a change
	[[[[self projectContainer] project] document] updateChangeCount:NSChangeDone];
}
- (IBAction)ungroupSelection:(id)sender; {
	// grab out selected group containers
	NSArray *selectedGroupContainers = [self selectedObjects];
	// keep the ungrouped containers here to select later
	NSMutableArray *ungroupedFileContainers = [NSMutableArray arrayWithCapacity:0];
	
	for (WCGroupContainer *groupContainer in selectedGroupContainers) {
		// we are removing each groupContainer from the outline view and inserting its children in its place
		[ungroupedFileContainers addObjectsFromArray:[groupContainer childNodes]];
		// have the tree controller actually move the child nodes for us
		[[self treeController] moveNodes:[[self treeController] treeNodesForRepresentedObjects:[groupContainer childNodes]] toIndexPath:[[self treeController] indexPathForRepresentedObject:groupContainer]];
	}
	
	// actually remove the group containers
	for (WCGroupContainer *groupContainer in selectedGroupContainers)
		[[[groupContainer parentNode] mutableChildNodes] removeObjectIdenticalTo:groupContainer];
	
	// select the ungrouped file containers we were keeping track of above
	[self setSelectedObjects:ungroupedFileContainers];
	
	// the set of removed group containers were those that were originally selected
	NSSet *removedGroups = [NSSet setWithArray:selectedGroupContainers];
	// the set of ungrouped nodes is the union of leaf nodes of the original group containers
	NSSet *ungroupedNodes = [NSSet setWithArray:[ungroupedFileContainers valueForKeyPath:@"@unionOfArrays.descendantLeafNodesInclusive"]];
	
	// post the appropriate notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidRemoveNodesNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:removedGroups,WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey, nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidUngroupNodesNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:ungroupedNodes,WCProjectNavigatorDidUngroupNodesNotificationUngroupedNodesUserInfoKey, nil]];
	
	// let the document know there was a change
	[[[[self projectContainer] project] document] updateChangeCount:NSChangeDone];
}

- (IBAction)delete:(id)sender; {
	[self handleDeletePressedForOutlineView:(RSOutlineView *)[self outlineView]];
}
- (IBAction)rename:(id)sender; {
	WCFileContainer *fileContainer = [[self selectedObjects] firstObject];
	
	[[self outlineView] editColumn:0 row:[[self outlineView] rowForItem:[[self treeController] treeNodeForRepresentedObject:fileContainer]] withEvent:nil select:YES];
}

- (IBAction)openInSeparateEditor:(id)sender; {
	
}
#pragma mark Properties
@synthesize outlineView=_outlineView;
@synthesize searchField=_searchField;
@synthesize treeController=_treeController;

@synthesize projectContainer=_projectContainer;
@synthesize filteredProjectContainer=_filteredProjectContainer;
@synthesize filterString=_filterString;
@dynamic switchTreeControllerContentBinding;
- (BOOL)switchTreeControllerContentBinding {
	return _projectNavigatorFlags.switchTreeControllerContentBinding;
}
- (void)setSwitchTreeControllerContentBinding:(BOOL)switchTreeControllerContentBinding {
	_projectNavigatorFlags.switchTreeControllerContentBinding = switchTreeControllerContentBinding;
}
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
#pragma mark *** Private Methods ***
- (BOOL)_deleteRequiresUserConfirmation:(BOOL *)projectContainerIsSelected; {
	BOOL deleteRequiresConfirmation = NO;
	for (id container in [self selectedObjects]) {
		if ([container isKindOfClass:[WCProjectContainer class]]) {
			if (projectContainerIsSelected)
				*projectContainerIsSelected = YES;
			return YES;
		}
		else if (!deleteRequiresConfirmation &&
				 [container isKindOfClass:[WCGroupContainer class]] &&
				 [[container descendantLeafNodes] count])
			deleteRequiresConfirmation = YES;
		else if (!deleteRequiresConfirmation &&
				 [container isMemberOfClass:[WCFileContainer class]])
			deleteRequiresConfirmation = YES;
	}
	if (projectContainerIsSelected)
		*projectContainerIsSelected = NO;
	
	return deleteRequiresConfirmation;
}
#pragma mark IBActions
- (IBAction)_outlineViewDoubleClick:(id)sender; {
	for (WCFileContainer *selectedNode in [self selectedObjects]) {
		if ([[selectedNode representedObject] isSourceFile])
			[[[[self projectContainer] project] document] openTabForFile:[selectedNode representedObject]];
	}
}
@end
