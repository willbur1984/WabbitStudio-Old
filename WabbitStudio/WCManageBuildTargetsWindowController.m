//
//  WCManageBuildTargetsWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCManageBuildTargetsWindowController.h"
#import "WCProjectDocument.h"
#import "WCBuildTarget.h"
#import "RSTableView.h"
#import "NSArray+WCExtensions.h"
#import "WCEditBuildTargetWindowController.h"
#import "RSDefines.h"
#import "WCAlertsViewController.h"
#import "NSAlert-OAExtensions.h"

@implementation WCManageBuildTargetsWindowController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
	[[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"Filter Build Targets", @"Filter Build Targets")];
	[[[[self searchField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self searchField] cell] searchButtonCell] setAlternateImage:nil];
	
	[[self tableView] setTarget:self];
	[[self tableView] setDoubleAction:@selector(_tableViewDoubleClick:)];
}

- (NSString *)windowNibName {
	return @"WCManageBuildTargetsWindow";
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(delete:) ||
		[menuItem action] == @selector(deleteBuildTarget:)) {
		
		NSArray *selectedBuildTargets = [self selectedBuildTargets];
		
		if ([selectedBuildTargets count] == 1)
			[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete \"%@\"", @"delete single build target menu item title format string"),[[selectedBuildTargets lastObject] name]]];
		else
			[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete %lu Build Targets", @"delete multiple build targets menu item title format string"),[selectedBuildTargets count]]];
		
		WCBuildTarget *activeBuildTarget = [[self projectDocument] activeBuildTarget];
		if ([selectedBuildTargets containsObject:activeBuildTarget])
			return NO;
	}
	else if ([menuItem action] == @selector(duplicateBuildTarget:)) {
		WCBuildTarget *buildTarget = [[self selectedBuildTargets] firstObject];
		
		if (buildTarget)
			[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Duplicate \"%@\"", @"duplicate single build target menu item title format string"),[buildTarget name]]];
	}
	else if ([menuItem action] == @selector(renameBuildTarget:)) {
		WCBuildTarget *buildTarget = [[self selectedBuildTargets] firstObject];
		
		if (buildTarget)
			[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rename \"%@\"", @"rename single build target menu item title format string"),[buildTarget name]]];
	}
	else if ([menuItem action] == @selector(makeActiveBuildTarget:)) {
		WCBuildTarget *buildTarget = [[self selectedBuildTargets] firstObject];
		
		if (buildTarget) {
			[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Make \"%@\" Active", @"make active build target menu item title format string"),[buildTarget name]]];
			
			if ([[self projectDocument] activeBuildTarget] == buildTarget)
				return NO;
		}
		else {
			[menuItem setTitle:NSLocalizedString(@"Make Active Build Target", @"Make Active Build Target")];
			
			return NO;
		}
	}
	return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return ([[fieldEditor string] length]);
}

- (void)handleDeletePressedForTableView:(RSTableView *)tableView {
	[self deleteBuildTarget:nil];
}
- (void)handleReturnPressedForTableView:(RSTableView *)tableView {
	[self newBuildTarget:nil];
}
- (void)handleSpacePressedForTableView:(RSTableView *)tableView {
	[self makeActiveBuildTarget:nil];
}

+ (id)manageBuildTargetsWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithProjectDocument:projectDocument] autorelease];
}
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}

- (void)showManageBuildTargetsWindow; {
	[self retain];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
}

- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
}
- (IBAction)editBuildTarget:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
}

static NSString *const kIconColumnIdentifier = @"icon";
static NSString *const kNameColumnIdentifier = @"name";

- (IBAction)newBuildTarget:(id)sender; {
	WCBuildTarget *newBuildTarget = [WCBuildTarget buildTargetWithName:NSLocalizedString(@"New Target", @"New Target") outputType:WCBuildTargetOutputTypeBinary projectDocument:[self projectDocument]];
	NSUInteger selectionIndex = [[[self arrayController] selectionIndexes] firstIndex];
	
	if (selectionIndex == NSNotFound)
		selectionIndex = [[[self arrayController] arrangedObjects] count];
	
	[[self arrayController] insertObject:newBuildTarget atArrangedObjectIndex:selectionIndex];
	
	[[self tableView] editColumn:[[self tableView] columnWithIdentifier:kNameColumnIdentifier] row:selectionIndex withEvent:nil select:YES];
}
- (IBAction)newBuildTargetFromTemplate:(id)sender; {
	
}
- (IBAction)deleteBuildTarget:(id)sender; {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBuildTargetsKey]) {
		NSString *message;
		if ([[[self arrayController] selectionIndexes] count] == 1)
			message = [NSString stringWithFormat:NSLocalizedString(@"Delete the Build Target \"%@\"?", @"delete build target alert single target message format string"),[(WCBuildTarget *)[[[self arrayController] selectedObjects] lastObject] name]];
		else
			message = [NSString stringWithFormat:NSLocalizedString(@"Delete %lu Build Targets?", @"delete build target alert multiple targets message format string"),[[[self arrayController] selectionIndexes] count]];
		
		NSAlert *deleteBuildTargetsAlert = [NSAlert alertWithMessageText:message defaultButton:LOCALIZED_STRING_DELETE alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:NSLocalizedString(@"This operation cannot be undone.", @"This operation cannot be undone.")];
		
		[deleteBuildTargetsAlert setShowsSuppressionButton:YES];
		
		[[deleteBuildTargetsAlert suppressionButton] bind:NSValueBinding toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:WCAlertsWarnBeforeDeletingBuildTargetsKey] options:nil];
		
		[deleteBuildTargetsAlert beginSheetModalForWindow:[self window] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert suppressionButton] unbind:NSValueBinding];
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self arrayController] removeObjectsAtArrangedObjectIndexes:[[self arrayController] selectionIndexes]];
		}];
	}
	else
		[[self arrayController] removeObjectsAtArrangedObjectIndexes:[[self arrayController] selectionIndexes]];
}
- (IBAction)duplicateBuildTarget:(id)sender; {
	WCBuildTarget *buildTarget = [[[self arrayController] selectedObjects] firstObject];
	WCBuildTarget *newBuildTarget = [[buildTarget mutableCopy] autorelease];
	NSUInteger insertIndex = [[[self arrayController] selectionIndexes] firstIndex];
	
	[[self arrayController] insertObject:newBuildTarget atArrangedObjectIndex:insertIndex];
	
	[[self tableView] editColumn:[[self tableView] columnWithIdentifier:kNameColumnIdentifier] row:insertIndex withEvent:nil select:YES];
}
- (IBAction)renameBuildTarget:(id)sender; {
	NSInteger clickedRow = [[self tableView] clickedRow];
	NSInteger clickedColumn = [[self tableView] clickedColumn];
	
	if (clickedRow == -1 || clickedColumn == -1) {
		NSUInteger selectedIndex = [[[self arrayController] selectionIndexes] firstIndex];
		
		[[self tableView] editColumn:[[self tableView] columnWithIdentifier:kNameColumnIdentifier] row:selectedIndex withEvent:nil select:YES];
		return;
	}
	
	[[self tableView] editColumn:clickedColumn row:clickedRow withEvent:nil select:YES];
}
- (IBAction)makeActiveBuildTarget:(id)sender; {
	WCBuildTarget *buildTarget = [[self selectedBuildTargets] firstObject];
	
	[[self projectDocument] setActiveBuildTarget:buildTarget];
}

@synthesize tableView=_tableView;
@synthesize arrayController=_arrayController;
@synthesize searchField=_searchField;

@synthesize projectDocument=_projectDocument;
@dynamic selectedBuildTargets;
- (NSArray *)selectedBuildTargets {
	NSInteger clickedRow = [[self tableView] clickedRow];
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if (clickedRow == -1 || [[[self tableView] selectedRowIndexes] containsIndex:clickedRow])
		[retval addObjectsFromArray:[[self arrayController] selectedObjects]];
	else {
		WCBuildTarget *clickedBuildTarget = [[[self arrayController] arrangedObjects] objectAtIndex:clickedRow];
		
		[retval addObject:clickedBuildTarget];
	}
	
	return [[retval copy] autorelease];
}
- (void)setSelectedBuildTargets:(NSArray *)selectedBuildTargets {
	[[self arrayController] setSelectedObjects:selectedBuildTargets];
}

- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context {
	[self autorelease];
	[sheet orderOut:nil];
	
	if (code == NSCancelButton)
		return;
	
	WCBuildTarget *buildTarget = [[[self arrayController] selectedObjects] firstObject];
	WCEditBuildTargetWindowController *windowController = [WCEditBuildTargetWindowController editBuildTargetWindowControllerWithBuildTarget:buildTarget];
	
	[windowController showEditBuildTargetWindow];
}

- (IBAction)_tableViewDoubleClick:(id)sender; {
	NSInteger clickedRow = [[self tableView] clickedRow];
	NSInteger clickedColumn = [[self tableView] clickedColumn];
	
	if (clickedRow == -1 || clickedColumn == -1) {
		[self newBuildTarget:nil];
		return;
	}
	
	[[self tableView] editColumn:clickedColumn row:clickedRow withEvent:nil select:YES];
}

@end
