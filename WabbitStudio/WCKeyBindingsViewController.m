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
#import "RSDefines.h"

@interface WCKeyBindingsViewController ()
@property (readwrite,copy,nonatomic) NSString *searchString;
@end

@implementation WCKeyBindingsViewController

#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_scopeBarItemIdentifiersToTitles release];
	[_scopeBarItemTitles release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_scopeBarItemTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"All", @"All"),NSLocalizedString(@"Customized", @"Customized"),NSLocalizedString(@"Conflicts", @"Conflicts"), nil];
	
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
	
	[[self outlineView] setTarget:self];
	[[self outlineView] setDoubleAction:@selector(_outlineViewDoubleClick:)];
	
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
	return [NSImage imageNamed:@"keyboard_settings"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return nil;
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
#pragma mark NSOutlineViewDelegate
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {	
	return (![[item representedObject] isLeafNode]);
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	return ([[item representedObject] isLeafNode]);
}
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([[[item representedObject] menuItem] isAlternate]) {
		NSMutableAttributedString *attributedString = [[[cell attributedStringValue] mutableCopy] autorelease];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor disabledControlTextColor],NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [attributedString length])];
		
		[cell setAttributedStringValue:attributedString];
	}
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

@synthesize scopeBar=_scopeBar;
@synthesize searchField=_searchField;
@synthesize arrayController=_arrayController;
@synthesize outlineView=_outlineView;
@synthesize initialFirstResponder=_initialFirstResponder;
@synthesize searchArrayController=_searchArrayController;
@synthesize searchString=_searchString;
@synthesize treeController=_treeController;

- (IBAction)_outlineViewDoubleClick:(id)sender; {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	if (clickedRow == -1) {
		NSBeep();
		return;
	}
	NSInteger selectedRow = [[self outlineView] selectedRow];
	if (selectedRow != clickedRow) {
		NSBeep();
		return;
	}
	
	[[WCKeyBindingsEditCommandPairWindowController sharedWindowController] showEditCommandPairSheetForCommandPair:[[[self outlineView] itemAtRow:clickedRow] representedObject]];
}

@end
