//
//  WCKeyBindingsViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingsViewController.h"
#import "MGScopeBar.h"
#import "WCKeyBindingCommandSetManager.h"
#import "WCKeyBindingCommandPair.h"
#import "WCKeyBindingsEditCommandPairWindowController.h"
#import "WCKeyBindingCommandSetManager.h"
#import "RSDefines.h"
#import "RSOutlineView.h"
#import "RSTableView.h"
#import "NSTreeController+RSExtensions.h"

NSString *const WCKeyBindingsCurrentCommandSetIdentifierKey = @"WCKeyBindingsCurrentCommandSetIdentifierKey";
NSString *const WCKeyBindingsUserCommandSetIdentifiersKey = @"WCKeyBindingsUserCommandSetIdentifiersKey";

@interface WCKeyBindingsViewController ()
@property (readwrite,copy,nonatomic) NSString *searchString;
@property (readwrite,copy,nonatomic) NSString *defaultShortcutString;
@property (readwrite,copy,nonatomic) NSArray *previousSelectionIndexPaths;
@end

@implementation WCKeyBindingsViewController

#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_scopeBarItemIdentifiersToTitles release];
	[_scopeBarItemTitles release];
	[_defaultShortcutString release];
	[_searchString release];
	[_previousSelectionIndexPaths release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_scopeBarItemTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"All", @"All"),NSLocalizedString(@"Customized", @"Customized"), nil];
	
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:[_scopeBarItemTitles count]];
	for (NSString *title in _scopeBarItemTitles)
		[temp setObject:title forKey:title];
	_scopeBarItemIdentifiersToTitles = [temp copy];
	
	return self;
}

- (NSString *)nibName {
	return @"WCKeyBindingsView";
}

- (void)loadView {
	[super loadView];
	
	[[self arrayController] bind:NSContentArrayBinding toObject:[WCKeyBindingCommandSetManager sharedManager] withKeyPath:@"commandSets" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
	
	[[self arrayController] setSelectedObjects:[NSArray arrayWithObject:[[WCKeyBindingCommandSetManager sharedManager] currentCommandSet]]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tableViewSelectionIsChanging:) name:NSTableViewSelectionIsChangingNotification object:[self tableView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tableViewSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:[self tableView]];
	
	[[self outlineView] setTarget:self];
	[[self outlineView] setDoubleAction:@selector(_outlineViewDoubleClick:)];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_outlineViewSelectionIsChanging:) name:NSOutlineViewSelectionIsChangingNotification object:[self outlineView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_outlineViewSelectionDidChange:) name:NSOutlineViewSelectionDidChangeNotification object:[self outlineView]];
	
	[[self outlineView] expandItem:nil expandChildren:YES];
	[[self outlineView] selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitstudio.keybindings";
}

- (NSString *)label {
	return NSLocalizedString(@"Key Bindings", @"Key Bindings");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"KeyBindings"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:@"org.revsoft.wabbitstudio.keybindingcommandset.default",WCKeyBindingsCurrentCommandSetIdentifierKey, nil];
}
#pragma mark MGScopeBarDelegate
static const NSInteger kNumberOfScopeBarGroups = 1;
- (NSInteger)numberOfGroupsInScopeBar:(MGScopeBar *)theScopeBar {
	return kNumberOfScopeBarGroups;
}
- (NSArray *)scopeBar:(MGScopeBar *)theScopeBar itemIdentifiersForGroup:(NSInteger)groupNumber {
	return _scopeBarItemTitles;
}
- (MGScopeBarGroupSelectionMode)scopeBar:(MGScopeBar *)theScopeBar selectionModeForGroup:(NSInteger)groupNumber {
	return MGRadioSelectionMode;
}
- (NSString *)scopeBar:(MGScopeBar *)theScopeBar labelForGroup:(NSInteger)groupNumber; {
	return nil;
}
- (NSString *)scopeBar:(MGScopeBar *)theScopeBar titleOfItem:(NSString *)identifier inGroup:(NSInteger)groupNumber {
	return [_scopeBarItemIdentifiersToTitles objectForKey:identifier];
}
- (NSView *)accessoryViewForScopeBar:(MGScopeBar *)theScopeBar {
	return [self searchField];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)item {
	if ([item action] == @selector(duplicateCommandSet:)) {
		WCKeyBindingCommandSet *commandSet = [[[self arrayController] selectedObjects] lastObject];
		
		[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Duplicate \"%@\"", @"duplicate command set format string"),[commandSet name]]];
	}
	return YES;
}
#pragma mark NSMenuDelegate
- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
	return [[[WCKeyBindingCommandSetManager sharedManager] defaultCommandSets] count];
}
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
	WCKeyBindingCommandSet *commandSet = [[[WCKeyBindingCommandSetManager sharedManager] defaultCommandSets] objectAtIndex:index];
	
	[item setTitle:[commandSet name]];
	[item setTarget:self];
	[item setAction:@selector(_newFromTemplateClicked:)];
	[item setRepresentedObject:commandSet];
	
	return YES;
}
#pragma mark NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return ([[fieldEditor string] length]);
}

#pragma mark NSOutlineViewDelegate
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {	
	return ([[[item representedObject] menuItem] menu] == [[NSApplication sharedApplication] mainMenu]);
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	return ([[[item representedObject] menuItem] menu] != [[NSApplication sharedApplication] mainMenu]);
}
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([[[item representedObject] menuItem] isAlternate]) {
		NSMutableAttributedString *attributedString = [[[cell attributedStringValue] mutableCopy] autorelease];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor disabledControlTextColor],NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [attributedString length])];
		
		[cell setAttributedStringValue:attributedString];
	}
}
- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation {
	BOOL isGroupItem = [self outlineView:outlineView isGroupItem:item];
	if (isGroupItem)
		return nil;
	NSString *key = [[WCKeyBindingCommandSetManager sharedManager] defaultKeyForMenuItem:[[item representedObject] menuItem]];
	return [NSString stringWithFormat:NSLocalizedString(@"Default shortcut: %@", @"default shortcut format string"),([key length])?key:NSLocalizedString(@"None", @"None")];
}
#pragma mark RSTableViewDelegate
- (void)handleDeletePressedForTableView:(RSTableView *)tableView {
	[self deleteCommandSet:nil];
}
#pragma mark RSOutlineViewDelegate
- (void)handleReturnPressedForOutlineView:(RSOutlineView *)outlineView {
	[[WCKeyBindingsEditCommandPairWindowController sharedWindowController] showEditCommandPairSheetForCommandPair:[[[self outlineView] itemAtRow:[[self outlineView] selectedRow]] representedObject]];
}

- (IBAction)search:(id)sender; {
	if ([[self searchString] length]) {
		[[self treeController] bind:NSContentArrayBinding toObject:[self searchArrayController] withKeyPath:@"arrangedObjects" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
	}
	else {
		[[self treeController] bind:NSContentArrayBinding toObject:[self arrayController] withKeyPath:@"selection.commandPairs" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
		[[self outlineView] expandItem:nil expandChildren:YES];
		[[self outlineView] selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	}
}

- (IBAction)deleteCommandSet:(id)sender; {
	if ([[[self arrayController] arrangedObjects] count] == 1) {
		NSBeep();
		return;
	}
	
	[[self arrayController] removeObjectsAtArrangedObjectIndexes:[[self arrayController] selectionIndexes]];
}
- (IBAction)duplicateCommandSet:(id)sender; {
	WCKeyBindingCommandSet *newCommandSet = [[[[[self arrayController] selectedObjects] lastObject] mutableCopy] autorelease];
	
	if ([[WCKeyBindingCommandSetManager sharedManager] containsCommandSet:newCommandSet]) {
		NSBeep();
		return;
	}
	
	[[self arrayController] addObject:newCommandSet];
	
	[self performSelector:@selector(_editSelectedCommandSetsTableViewRow) withObject:nil afterDelay:0.0];
}

@synthesize scopeBar=_scopeBar;
@synthesize searchField=_searchField;
@synthesize arrayController=_arrayController;
@synthesize outlineView=_outlineView;
@synthesize initialFirstResponder=_initialFirstResponder;
@synthesize searchArrayController=_searchArrayController;
@synthesize searchString=_searchString;
@synthesize treeController=_treeController;
@synthesize tableView=_tableView;
@synthesize defaultShortcutString=_defaultShortcutString;
@synthesize previousSelectionIndexPaths=_previousSelectionIndexPaths;

- (void)_editSelectedCommandSetsTableViewRow; {
	[[self tableView] editColumn:0 row:[[self tableView] selectedRow] withEvent:nil select:YES];
}

- (IBAction)_outlineViewDoubleClick:(id)sender; {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	if (clickedRow == -1) {
		NSBeep();
		return;
	}
	NSInteger selectedRow = [[self outlineView] selectedRow];
	if (selectedRow == -1 || selectedRow != clickedRow) {
		NSBeep();
		return;
	}
	
	[[WCKeyBindingsEditCommandPairWindowController sharedWindowController] showEditCommandPairSheetForCommandPair:[[[self outlineView] itemAtRow:clickedRow] representedObject]];
}

- (IBAction)_newFromTemplateClicked:(id)sender; {
	WCKeyBindingCommandSet *newCommandSet = [[[sender representedObject] mutableCopy] autorelease];
	
	if ([[WCKeyBindingCommandSetManager sharedManager] containsCommandSet:newCommandSet]) {
		NSBeep();
		return;
	}
	
	[[self arrayController] addObject:newCommandSet];
	
	[self performSelector:@selector(_editSelectedCommandSetsTableViewRow) withObject:nil afterDelay:0.0];
}

- (void)_tableViewSelectionIsChanging:(NSNotification *)note {
	[self setPreviousSelectionIndexPaths:[[self treeController] selectionIndexPaths]];
}
- (void)_tableViewSelectionDidChange:(NSNotification *)note {
	[[WCKeyBindingCommandSetManager sharedManager] setCurrentCommandSet:[[[self arrayController] selectedObjects] lastObject]];
	
	[[self outlineView] expandItem:nil expandChildren:YES];
	//[[self treeController] setSelectionIndexPaths:[self previousSelectionIndexPaths]];
}
- (void)_outlineViewSelectionDidChange:(NSNotification *)note {
	WCKeyBindingCommandPair *pair = [[self treeController] selectedRepresentedObject];
	
	if (pair) {
		NSString *key = [[WCKeyBindingCommandSetManager sharedManager] defaultKeyForMenuItem:[pair menuItem]];
		
		[self setDefaultShortcutString:[NSString stringWithFormat:NSLocalizedString(@"Default shortcut: %@", @"default shortcut format string"),([key length])?key:NSLocalizedString(@"None", @"None")]];
	}
	else
		[self setDefaultShortcutString:nil];
}

@end
