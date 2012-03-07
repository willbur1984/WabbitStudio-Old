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

@interface WCManageBuildTargetsWindowController ()
- (void)_startObservingBuildTarget:(WCBuildTarget *)buildTarget;
- (void)_stopObservingBuildTarget:(WCBuildTarget *)buildTarget;
@end

@implementation WCManageBuildTargetsWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WCManageBuildTargetsWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
	[[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"Filter Build Targets", @"Filter Build Targets")];
	[[[[self searchField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self searchField] cell] searchButtonCell] setAlternateImage:nil];
	
	[[self tableView] setTarget:self];
	[[self tableView] setDoubleAction:@selector(_tableViewDoubleClick:)];
}
#pragma mark NSMenuValidation
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
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == self) {
		if ([keyPath isEqualToString:@"buildTargets"]) {
			NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
			
			if (changeKind == NSKeyValueChangeInsertion) {
				NSArray *buildTargets = [change objectForKey:NSKeyValueChangeNewKey];
				
				for (WCBuildTarget *buildTarget in buildTargets)
					[self _startObservingBuildTarget:buildTarget];
			}
			else if (changeKind == NSKeyValueChangeRemoval) {
				NSArray *buildTargets = [change objectForKey:NSKeyValueChangeOldKey];
				
				for (WCBuildTarget *buildTarget in buildTargets)
					[self _stopObservingBuildTarget:buildTarget];
			}
			
			[[self projectDocument] updateChangeCount:NSChangeDone];
		}
		else if ([keyPath isEqualToString:@"name"]) {
			[[self projectDocument] updateChangeCount:NSChangeDone];
		}
		else if ([keyPath isEqualToString:@"active"]) {
			[[self projectDocument] updateChangeCount:NSChangeDone];
		}
		else if ([keyPath isEqualToString:@"outputType"]) {
			[[self projectDocument] updateChangeCount:NSChangeDone];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return ([[fieldEditor string] length]);
}
#pragma mark RSTableViewDelegate
- (void)handleDeletePressedForTableView:(RSTableView *)tableView {
	[self deleteBuildTarget:nil];
}
- (void)handleReturnPressedForTableView:(RSTableView *)tableView {
	[self newBuildTarget:nil];
}
- (void)handleSpacePressedForTableView:(RSTableView *)tableView {
	[self makeActiveBuildTarget:nil];
}
#pragma mark *** Public Methods ***
+ (id)manageBuildTargetsWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithProjectDocument:projectDocument] autorelease];
}
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_projectDocument = projectDocument;
	
	[projectDocument addObserver:self forKeyPath:@"buildTargets" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:self];
	
	for (WCBuildTarget *buildTarget in [projectDocument buildTargets])
		[self _startObservingBuildTarget:buildTarget];
	
	return self;
}

- (void)showManageBuildTargetsWindow; {
	[self retain];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
}
#pragma mark IBActions
- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
}
- (IBAction)editBuildTarget:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
}

static NSString *const kIconColumnIdentifier = @"icon";
static NSString *const kNameColumnIdentifier = @"name";
static NSString *const kOutputTypeColumnIdentifier = @"outputType";

- (IBAction)newBuildTarget:(id)sender; {
	WCBuildTarget *newBuildTarget = [WCBuildTarget buildTargetWithName:NSLocalizedString(@"New Target", @"New Target") outputType:WCBuildTargetOutputTypeBinary projectDocument:[self projectDocument]];
	
	if (![[[self projectDocument] buildTargets] count])
		[newBuildTarget setActive:YES];
	
	NSUInteger selectionIndex = [[[self arrayController] selectionIndexes] firstIndex];
	
	if (selectionIndex == NSNotFound)
		selectionIndex = [[[self arrayController] arrangedObjects] count];
	
	[[self arrayController] insertObject:newBuildTarget atArrangedObjectIndex:selectionIndex];
	
	[[self tableView] editColumn:[[self tableView] columnWithIdentifier:kNameColumnIdentifier] row:[[[self arrayController] arrangedObjects] indexOfObjectIdenticalTo:newBuildTarget] withEvent:nil select:YES];
}
- (IBAction)newBuildTargetFromTemplate:(id)sender; {
	
}
- (IBAction)deleteBuildTarget:(id)sender; {
	if ([[[self arrayController] selectedObjects] indexOfObjectIdenticalTo:[[self projectDocument] activeBuildTarget]] != NSNotFound) {
		NSBeep();
		return;
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCAlertsWarnBeforeDeletingBuildTargetsKey]) {
		NSString *message;
		if ([[[self arrayController] selectionIndexes] count] == 1)
			message = [NSString stringWithFormat:NSLocalizedString(@"Delete the Build Target \"%@\"?", @"delete build target alert single target message format string"),[(WCBuildTarget *)[[[self arrayController] selectedObjects] lastObject] name]];
		else
			message = [NSString stringWithFormat:NSLocalizedString(@"Delete %lu Build Targets?", @"delete build target alert multiple targets message format string"),[[[self arrayController] selectionIndexes] count]];
		
		NSAlert *deleteBuildTargetsAlert = [NSAlert alertWithMessageText:message defaultButton:LOCALIZED_STRING_DELETE alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:NSLocalizedString(@"This operation cannot be undone.", @"This operation cannot be undone.")];
		
		[deleteBuildTargetsAlert setShowsSuppressionButton:YES];
		
		[[deleteBuildTargetsAlert suppressionButton] bind:NSValueBinding toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:WCAlertsWarnBeforeDeletingBuildTargetsKey] options:[NSDictionary dictionaryWithObjectsAndKeys:NSNegateBooleanTransformerName,NSValueTransformerNameBindingOption, nil]];
		
		[deleteBuildTargetsAlert beginSheetModalForWindow:[self window] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert suppressionButton] unbind:NSValueBinding];
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self arrayController] removeObjectsAtArrangedObjectIndexes:[[self arrayController] selectionIndexes]];
		}];
	}
	else {
		[[self arrayController] removeObjectsAtArrangedObjectIndexes:[[self arrayController] selectionIndexes]];
	}
}
- (IBAction)duplicateBuildTarget:(id)sender; {
	WCBuildTarget *buildTarget = [[[self arrayController] selectedObjects] firstObject];
	WCBuildTarget *newBuildTarget = [[buildTarget mutableCopy] autorelease];
	NSUInteger insertIndex = [[[self arrayController] selectionIndexes] firstIndex];
	
	[[self arrayController] insertObject:newBuildTarget atArrangedObjectIndex:insertIndex];
	
	[[self tableView] editColumn:[[self tableView] columnWithIdentifier:kNameColumnIdentifier] row:[[[self arrayController] arrangedObjects] indexOfObjectIdenticalTo:newBuildTarget] withEvent:nil select:YES];
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
	WCBuildTarget *activeBuildTarget = [[self projectDocument] activeBuildTarget];
	
	if (buildTarget == activeBuildTarget) {
		NSBeep();
		return;
	}
	
	[[self projectDocument] setActiveBuildTarget:buildTarget];
}
#pragma mark Properties
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
#pragma mark *** Private Methods ***
- (void)_startObservingBuildTarget:(WCBuildTarget *)buildTarget; {
	[buildTarget addObserver:self forKeyPath:@"name" options:0 context:self];
	[buildTarget addObserver:self forKeyPath:@"outputType" options:0 context:self];
	[buildTarget addObserver:self forKeyPath:@"active" options:0 context:self];
}
- (void)_stopObservingBuildTarget:(WCBuildTarget *)buildTarget; {
	[buildTarget removeObserver:self forKeyPath:@"name" context:self];
	[buildTarget removeObserver:self forKeyPath:@"outputType" context:self];
	[buildTarget removeObserver:self forKeyPath:@"active" context:self];
}
#pragma mark IBActions
- (IBAction)_tableViewDoubleClick:(id)sender; {
	NSInteger clickedRow = [[self tableView] clickedRow];
	NSInteger clickedColumn = [[self tableView] clickedColumn];
	
	if (clickedRow == -1 || clickedColumn == -1) {
		[self newBuildTarget:nil];
		return;
	}
	
	[[self tableView] editColumn:clickedColumn row:clickedRow withEvent:nil select:YES];
}

#pragma mark Callbacks
- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context {
	[self autorelease];
	[sheet orderOut:nil];
	[[self projectDocument] removeObserver:self forKeyPath:@"buildTargets" context:self];
	for (WCBuildTarget *buildTarget in [[self projectDocument] buildTargets])
		[self _stopObservingBuildTarget:buildTarget];
	
	if (code == NSCancelButton)
		return;
	
	WCBuildTarget *buildTarget = [[[self arrayController] selectedObjects] firstObject];
	WCEditBuildTargetWindowController *windowController = [WCEditBuildTargetWindowController editBuildTargetWindowControllerWithBuildTarget:buildTarget];
	
	[windowController showEditBuildTargetWindow];
}

@end
