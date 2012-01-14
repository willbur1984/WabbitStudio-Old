//
//  WCFontsAndColorsViewController.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFontsAndColorsViewController.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "WCFontAndColorThemePair.h"
#import "RSTableView.h"

NSString *const WCFontsAndColorsCurrentThemeIdentifierKey = @"WCFontsAndColorsCurrentThemeIdentifierKey";
NSString *const WCFontsAndColorsUserThemeIdentifiersKey = @"WCFontsAndColorsUserThemeIdentifiersKey";

@interface WCFontsAndColorsViewController ()
- (void)_editSelectedThemesTableViewRow;
@end

@implementation WCFontsAndColorsViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (id)init {
	return [self initWithNibName:[self nibName] bundle:nil];
}

- (NSString *)nibName {
	return @"WCFontsAndColorsView";
}

- (void)loadView {
	[super loadView];
	
	[[self themesArrayController] bind:NSContentArrayBinding toObject:[WCFontAndColorThemeManager sharedManager] withKeyPath:@"themes" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
	
	[[self pairsTableView] bind:@"backgroundColor" toObject:[self themesArrayController] withKeyPath:@"selection.backgroundColor" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
	
	[[self themesArrayController] setSelectedObjects:[NSArray arrayWithObject:[[WCFontAndColorThemeManager sharedManager] currentTheme]]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_themesTableViewSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:[self themesTableView]];
}

- (IBAction)changeFont:(id)sender {
	WCFontAndColorThemePair *selectedPair = [[[self pairsArrayController] selectedObjects] lastObject];
	NSFont *newFont = [sender convertFont:[selectedPair font]];
	
	[selectedPair setFont:newFont];
	
	[[self pairsTableView] noteHeightOfRowsWithIndexesChanged:[[self pairsArrayController] selectionIndexes]];
}
#pragma mark NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return ([[fieldEditor string] length]);
}
#pragma mark NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {	
	CGFloat rowHeight = [tableView rowHeight];
	if (row == -1)
		return rowHeight;
	
	NSTextFieldCell *rowCell = (NSTextFieldCell *)[tableView preparedCellAtColumn:0 row:row];
	NSSize cellSize = [rowCell cellSizeForBounds:NSMakeRect(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
	
	if (cellSize.height > rowHeight)
		rowHeight = cellSize.height;
	
	return rowHeight;
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)item {
	if ([item action] == @selector(duplicateTheme:)) {
		WCFontAndColorTheme *theme = [[[self themesArrayController] selectedObjects] lastObject];
		
		[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Duplicate \"%@\"", @"duplicate theme format string"),[theme name]]];
	}
	return YES;
}
#pragma mark NSMenuDelegate
- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
	return [[[WCFontAndColorThemeManager sharedManager] defaultThemes] count];
}
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
	WCFontAndColorTheme *theme = [[[WCFontAndColorThemeManager sharedManager] defaultThemes] objectAtIndex:index];
	
	[item setTitle:[theme name]];
	[item setTarget:self];
	[item setAction:@selector(_newFromTemplateClicked:)];
	[item setRepresentedObject:theme];
	
	return YES;
}
#pragma mark RSTableViewDelegate
- (void)handleDeletePressedForTableView:(RSTableView *)tableView {
	if (tableView == [self themesTableView])
		[self deleteTheme:nil];
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitstudio.fontsandcolors";
}

- (NSString *)label {
	return NSLocalizedString(@"Fonts & Colors", @"Fonts & Colors");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"FontsAndColors"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return nil;
}
#pragma mark *** Public Methods ***
#pragma mark IBActions
- (IBAction)chooseFont:(id)sender; {
	//_oldWindowDelegate = [[[self view] window] delegate];
	
	//[[[self view] window] setDelegate:self];
	
	WCFontAndColorThemePair *selectedPair = [[[self pairsArrayController] selectedObjects] lastObject];
	
	[[NSFontPanel sharedFontPanel] setPanelFont:[selectedPair font] isMultiple:NO];
	[[NSFontPanel sharedFontPanel] makeKeyAndOrderFront:nil];
	
	/*
	_fontPanelWillCloseObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:[NSFontPanel sharedFontPanel] queue:nil usingBlock:^(NSNotification *note) {
		[[[self view] window] setDelegate:_oldWindowDelegate];
		
		[[NSNotificationCenter defaultCenter] removeObserver:_fontPanelWillCloseObservingToken];
		_fontPanelWillCloseObservingToken = nil;
	}];
	 */
}
- (IBAction)deleteTheme:(id)sender; {
	if ([[[self themesArrayController] arrangedObjects] count] == 1) {
		NSBeep();
		return;
	}
	
	[[self themesArrayController] removeObjectsAtArrangedObjectIndexes:[[self themesArrayController] selectionIndexes]];
}
- (IBAction)duplicateTheme:(id)sender; {
	WCFontAndColorTheme *newTheme = [[[[[self themesArrayController] selectedObjects] lastObject] mutableCopy] autorelease];
	
	if ([[WCFontAndColorThemeManager sharedManager] containsTheme:newTheme]) {
		NSBeep();
		return;
	}
	
	[[self themesArrayController] addObject:newTheme];
	
	[self performSelector:@selector(_editSelectedThemesTableViewRow) withObject:nil afterDelay:0.0];
}
#pragma mark Properties
@synthesize initialFirstResponder=_initialFirstResponder;
@synthesize themesArrayController=_themesArrayController;
@synthesize pairsArrayController=_pairsArrayController;
@synthesize themesTableView=_themesTableView;
@synthesize pairsTableView=_pairsTableView;
#pragma mark *** Private Methods ***
- (void)_editSelectedThemesTableViewRow; {
	[[self themesTableView] editColumn:0 row:[[self themesTableView] selectedRow] withEvent:nil select:YES];
}
#pragma mark IBActions
- (IBAction)_newFromTemplateClicked:(NSMenuItem *)sender {
	WCFontAndColorTheme *newTheme = [[[sender representedObject] mutableCopy] autorelease];
	
	if ([[WCFontAndColorThemeManager sharedManager] containsTheme:newTheme]) {
		NSBeep();
		return;
	}
	
	[[self themesArrayController] addObject:newTheme];
	
	[self performSelector:@selector(_editSelectedThemesTableViewRow) withObject:nil afterDelay:0.0];
}
#pragma mark Notifications
- (void)_themesTableViewSelectionDidChange:(NSNotification *)note {
	[[WCFontAndColorThemeManager sharedManager] setCurrentTheme:[[[self themesArrayController] selectedObjects] lastObject]];
	
	[[self pairsTableView] noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[[self pairsArrayController] arrangedObjects] count])]];
}

@end
