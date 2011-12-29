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

NSString *const WCFontsAndColorsCurrentThemeIdentifierKey = @"WCFontsAndColorsCurrentThemeIdentifierKey";

@implementation WCFontsAndColorsViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (id)init {
	return [self initWithNibName:@"WCFontsAndColorsView" bundle:nil];
}

- (void)loadView {
	[super loadView];
	
	[[self themesArrayController] bind:NSContentArrayBinding toObject:[WCFontAndColorThemeManager sharedManager] withKeyPath:@"themes" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
	
	[[self pairsTableView] bind:@"backgroundColor" toObject:[self themesArrayController] withKeyPath:@"selection.backgroundColor" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSRaisesForNotApplicableKeysBindingOption, nil]];
	
	[[self themesArrayController] setSelectedObjects:[NSArray arrayWithObject:[[WCFontAndColorThemeManager sharedManager] currentTheme]]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_themesTableViewSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:[self themesTableView]];
}

- (IBAction)changeFont:(id)sender {
	if (_fontPanelWillCloseObservingToken) {
		WCFontAndColorThemePair *selectedPair = [[[self pairsArrayController] selectedObjects] lastObject];
		NSFont *newFont = [sender convertFont:[selectedPair font]];
		
		[selectedPair setFont:newFont];
		
		[[self pairsTableView] noteHeightOfRowsWithIndexesChanged:[[self pairsArrayController] selectionIndexes]];
	}
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
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitcode.fontsandcolors";
}

- (NSString *)label {
	return NSLocalizedString(@"Fonts & Colors", @"Fonts & Colors");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"FontsAndColors"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[WCFontAndColorThemeDefaultTheme identifier],WCFontsAndColorsCurrentThemeIdentifierKey, nil];
}
#pragma mark *** Public Methods ***
#pragma mark IBActions
- (IBAction)chooseFont:(id)sender; {
	_oldWindowDelegate = [[[self view] window] delegate];
	
	[[[self view] window] setDelegate:self];
	
	WCFontAndColorThemePair *selectedPair = [[[self pairsArrayController] selectedObjects] lastObject];
	
	[[NSFontPanel sharedFontPanel] setPanelFont:[selectedPair font] isMultiple:NO];
	[[NSFontPanel sharedFontPanel] makeKeyAndOrderFront:nil];
	
	_fontPanelWillCloseObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:[NSFontPanel sharedFontPanel] queue:nil usingBlock:^(NSNotification *note) {
		[[[self view] window] setDelegate:_oldWindowDelegate];
		
		[[NSNotificationCenter defaultCenter] removeObserver:_fontPanelWillCloseObservingToken];
		_fontPanelWillCloseObservingToken = nil;
	}];
}
#pragma mark Properties
@synthesize initialFirstResponder=_initialFirstResponder;
@synthesize themesArrayController=_themesArrayController;
@synthesize pairsArrayController=_pairsArrayController;
@synthesize themesTableView=_themesTableView;
@synthesize pairsTableView=_pairsTableView;
#pragma mark *** Private Methods ***
#pragma mark Notifications
- (void)_themesTableViewSelectionDidChange:(NSNotification *)note {
	[[WCFontAndColorThemeManager sharedManager] setCurrentTheme:[[[self themesArrayController] selectedObjects] lastObject]];
	
	[[self pairsTableView] noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[[self pairsArrayController] arrangedObjects] count])]];
}

@end
