//
//  WCJumpBarViewController.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCJumpBarViewController.h"
#import "WCJumpBar.h"
#import "WCJumpBarComponentCell.h"
#import "WCSourceSymbol.h"
#import "WCSourceScanner.h"
#import "NSArray+WCExtensions.h"
#import "NSString+RSExtensions.h"
#import "NSEvent+RSExtensions.h"
#import "NSAttributedString+WCExtensions.h"
#import "WCReallyAdvancedViewController.h"
#import "NSObject+WCExtensions.h"
#import "NSImage+RSExtensions.h"
#import "WCDocumentController.h"
#import "NSURL+RSExtensions.h"
#import "RSDefines.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "WCFileContainer.h"
#import "WCProjectNavigatorViewController.h"
#import "WCProjectWindowController.h"
#import "WCSourceFileDocument.h"

@interface WCJumpBarViewController ()
@property (readwrite,copy,nonatomic) NSString *textViewSelectedLineAndColumn;
@property (readonly,nonatomic) NSMenu *symbolsMenu;
@property (readonly,nonatomic) id <WCJumpBarDataSource> jumpBarDataSource;
@property (readwrite,copy,nonatomic) NSArray *includesFiles;
@property (readwrite,assign,nonatomic) NSMenu *filesMenu;
@property (readonly,nonatomic) NSMapTable *fileSubmenusToFileContainers;
@property (readwrite,copy,nonatomic) NSArray *unsavedFiles;

- (void)_updatePathComponentCells;
- (void)_updateFilePathComponentCell;
- (void)_updateSymbolPathComponentCell;
- (void)_updateTextViewSelectedLineAndColumn;
- (void)_showMenuForPathComponentCell:(NSPathComponentCell *)clickedCell;
- (void)_updateSymbolsMenuItemsWithSymbols:(NSArray *)symbols selectedSymbol:(WCSourceSymbol *)selectedSymbol selectedSymbolIndex:(NSUInteger *)selectedSymbolIndex sortedByName:(BOOL)sortedByName;
@end

@implementation WCJumpBarViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanUpUserDefaultsObserving];
	_textView = nil;
	_jumpBarDataSource = nil;
	[_unsavedFiles release];
	[_includesFiles release];
	[_symbolsMenu release];
	[_filesMenu release];
	[_fileSubmenusToFileContainers release];
	[_textViewSelectedLineAndColumn release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCJumpBarView";
}

- (void)loadView {
	[super loadView];
	
	[[self jumpBar] setTarget:self];
	[[self jumpBar] setAction:@selector(_jumpBarClicked:)];
	
	[self _updatePathComponentCells];
}

- (NSSet *)userDefaultsKeyPathsToObserve {
	return [NSSet setWithObjects:WCReallyAdvancedJumpBarShowFileAndLineNumberKey, nil];
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCReallyAdvancedJumpBarShowFileAndLineNumberKey]]) {
		[self _updateSymbolPathComponentCell];
	}
	else if ([keyPath isEqualToString:@"icon"]) {
		[self _updateFilePathComponentCell];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
#pragma mark NSMenuDelegate
- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
	if (menu == [self recentFilesMenu]) {
		NSUInteger recentFilesCount = [[[WCDocumentController sharedDocumentController] recentDocumentURLs] count];
		if (!recentFilesCount)
			recentFilesCount++;
		return recentFilesCount;
	}
	else if (menu == [self unsavedFilesMenu]) {
		NSArray *temp = [[[[self jumpBarDataSource] projectDocument] unsavedFiles] allObjects];
		
		[self setUnsavedFiles:temp];
		
		if ([temp count])
			return [temp count];
		return 1;
	}
	else if (menu == [self includesMenu]) {
		if ([[self jumpBarDataSource] projectDocument]) {
			NSSet *includes = [[[self jumpBarDataSource] sourceScanner] includes];
			NSDictionary *filePathsToFiles = [[[self jumpBarDataSource] projectDocument] filePathsToFiles];
			NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
			
			[filePathsToFiles enumerateKeysAndObjectsUsingBlock:^(NSString *filePath, WCFile *file, BOOL *stop) {
				for (NSString *fileName in includes) {
					if ([filePath hasSuffix:fileName]) {
						[temp addObject:file];
						break;
					}
				}
			}];
			
			[temp sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
			
			[self setIncludesFiles:temp];
			
			if ([temp count])
				return [temp count];
			return 1;
		}
		return 1;
	}
	else if (menu == [self filesMenu])
		return [menu numberOfItems];
	else {
		WCFile *file = [[[menu supermenu] itemAtIndex:[[menu supermenu] indexOfItemWithSubmenu:menu]] representedObject];
		WCFileContainer *fileContainer = [[[self jumpBarDataSource] projectDocument] fileContainerForFile:file];
	
		[[self fileSubmenusToFileContainers] setObject:fileContainer forKey:menu];
		
		return [[fileContainer childNodes] count];
	}
}
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
	if (menu == [self recentFilesMenu]) {
		NSArray *fileURLs = [[WCDocumentController sharedDocumentController] recentDocumentURLs];
		
		if ([fileURLs count]) {
			NSURL *fileURL = [fileURLs objectAtIndex:index];
			
			[item setTitle:[fileURL fileName]];
			[item setImage:[fileURL fileIcon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:fileURL];
			[item setTarget:self];
			[item setAction:@selector(_recentFilesMenuItemClicked:)];
		}
		else {
			[item setTitle:NSLocalizedString(@"No Recent Files", @"No Recent Files")];
			[item setTarget:nil];
			[item setAction:NULL];
			[item setRepresentedObject:nil];
			[item setImage:nil];
		}
	}
	else if (menu == [self unsavedFilesMenu]) {
		if ([[self unsavedFiles] count]) {
			WCFile *file = [[self unsavedFiles] objectAtIndex:index];
			
			[item setTitle:[file fileName]];
			[item setImage:[file fileIcon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:file];
			[item setTarget:self];
			[item setAction:@selector(_unsavedFilesMenuItemClicked:)];
		}
		else {
			[item setTitle:NSLocalizedString(@"No Unsaved Files", @"No Unsaved Files")];
			[item setTarget:nil];
			[item setAction:NULL];
			[item setRepresentedObject:nil];
			[item setImage:nil];
		}
	}
	else if (menu == [self includesMenu]) {
		if ([[self includesFiles] count]) {
			WCFile *file = [[self includesFiles] objectAtIndex:index];
			
			[item setTitle:[file fileName]];
			[item setImage:[file fileIcon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:file];
			[item setTarget:self];
			[item setAction:@selector(_includesMenuItemClicked:)];
		}
		else {
			[item setTitle:NSLocalizedString(@"No Includes", @"No Includes")];
			[item setTarget:nil];
			[item setAction:NULL];
			[item setRepresentedObject:nil];
		}
	}
	else if (menu != [self filesMenu]) {
		WCFileContainer *fileContainer = [[self fileSubmenusToFileContainers] objectForKey:menu];
		WCFileContainer *childContainer = [[fileContainer childNodes] objectAtIndex:index];
		WCFile *file = [childContainer representedObject];
		
		[item setTarget:self];
		[item setAction:@selector(_filesMenuItemClicked:)];
		[item setTitle:[file fileName]];
		[item setImage:[file fileIcon]];
		[[item image] setSize:NSSmallSize];
		[item setRepresentedObject:file];
		
		if (![childContainer isLeafNode]) {
			NSMenu *submenu = [[[NSMenu alloc] initWithTitle:[item title]] autorelease];
			[submenu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
			[submenu setDelegate:self];
			
			[item setSubmenu:submenu];
		}
	}
	
	return (!shouldCancel);
}
- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(id *)target action:(SEL *)action {
	return NO;
}
- (void)menuWillOpen:(NSMenu *)menu {
	if (menu == [self filesMenu])
		_fileSubmenusToFileContainers = [[NSMapTable mapTableWithWeakToWeakObjects] retain];
}
- (void)menuDidClose:(NSMenu *)menu {
	if (menu == [self filesMenu]) {
		[_fileSubmenusToFileContainers release];
		_fileSubmenusToFileContainers = nil;
	}
	
	[self setIncludesFiles:nil];
	[self setFilesMenu:nil];
	[self setUnsavedFiles:nil];
}

#pragma mark *** Public Methods ***
- (id)initWithTextView:(NSTextView *)textView jumpBarDataSource:(id <WCJumpBarDataSource>)jumpBarDataSource; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_textView = textView;
	_jumpBarDataSource = jumpBarDataSource;
	_symbolsMenu = [[NSMenu alloc] initWithTitle:@""];
	[_symbolsMenu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	
	_textViewSelectedLineAndColumn = [NSLocalizedString(@"1:0", @"1:0") copy];
	
	[self setupUserDefaultsObserving];
	
	[(NSObject *)jumpBarDataSource addObserver:self forKeyPath:@"icon" options:NSKeyValueObservingOptionNew context:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:textView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:[jumpBarDataSource sourceScanner]];
	
	if ([jumpBarDataSource projectDocument]) {
		WCProjectNavigatorViewController *viewController = [[[jumpBarDataSource projectDocument] projectWindowController] projectNavigatorViewController];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidGroupNodes:) name:WCProjectNavigatorDidGroupNodesNotification object:viewController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidUngroupNodes:) name:WCProjectNavigatorDidUngroupNodesNotification object:viewController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidRenameNode:) name:WCProjectNavigatorDidRenameNodeNotification object:viewController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidMoveNodes:) name:WCProjectNavigatorDidMoveNodesNotification object:viewController];
	}
	
	return self;
}

- (void)performCleanup; {
	[(id)[self jumpBarDataSource] removeObserver:self forKeyPath:@"icon" context:self];
}
#pragma mark IBActions
- (IBAction)showTopLevelItems:(id)sender; {
	[self _showMenuForPathComponentCell:[[[self jumpBar] pathComponentCells] objectAtIndex:0]];
}
- (IBAction)showGroupItems:(id)sender; {
	NSArray *pathCells = [[self jumpBar] pathComponentCells];
	[self _showMenuForPathComponentCell:[pathCells objectAtIndex:[pathCells count]-2]];
}
- (IBAction)showDocumentItems:(id)sender; {
	[self _showMenuForPathComponentCell:[[[self jumpBar] pathComponentCells] lastObject]];
}
#pragma mark Properties
@synthesize jumpBar=_jumpBar;
@synthesize recentFilesMenu=_recentFilesMenu;
@synthesize unsavedFilesMenu=_unsavedFilesMenu;
@synthesize includesMenu=_includesMenu;

@synthesize jumpBarDataSource=_jumpBarDataSource;
@synthesize textView=_textView;
@dynamic additionalEffectiveSplitViewRect;
- (NSRect)additionalEffectiveSplitViewRect {
	NSRect jumpBarBounds = [[self jumpBar] bounds];
	NSRect symbolCellBounds = [(NSPathCell *)[[self jumpBar] cell] rectOfPathComponentCell:[[[self jumpBar] pathComponentCells] lastObject] withFrame:jumpBarBounds inView:[self jumpBar]];
	
	return [[self view] convertRect:NSMakeRect(NSMaxX(symbolCellBounds), NSMinY([[self view] bounds]), NSWidth([[self view] bounds])-NSMaxX(symbolCellBounds), NSHeight([[self view] bounds])) fromView:[self jumpBar]];
}

@synthesize textViewSelectedLineAndColumn=_textViewSelectedLineAndColumn;
@synthesize symbolsMenu=_symbolsMenu;
@synthesize includesFiles=_includesFiles;
@synthesize filesMenu=_filesMenu;
@synthesize fileSubmenusToFileContainers=_fileSubmenusToFileContainers;
@synthesize unsavedFiles=_unsavedFiles;
@synthesize addAssistantEditorButton=_addAssistantEditorButton;
@synthesize removeAssistantEditorButton=_removeAssistantEditorButton;
@synthesize rightVerticalSeparator=_rightVerticalSeparator;
#pragma mark *** Private Methods ***
- (void)_updatePathComponentCells; {
	if (![self jumpBarDataSource])
		return;
	
	NSMutableArray *pathCells = [NSMutableArray arrayWithCapacity:0];
	
	[pathCells addObjectsFromArray:[[self jumpBarDataSource] jumpBarComponentCells]];
	
	[pathCells addObject:[[[WCJumpBarComponentCell alloc] initTextCell:NSLocalizedString(@"No Symbols", @"No Symbols")] autorelease]];
	
	[[self jumpBar] setPathComponentCells:pathCells];
}

- (void)_updateFilePathComponentCell; {
	NSMutableArray *pathCells = [[[[self jumpBar] pathComponentCells] mutableCopy] autorelease];
	
	[pathCells replaceObjectAtIndex:[pathCells count]-2 withObject:[[self jumpBarDataSource] fileComponentCell]];
	
	[[self jumpBar] setPathComponentCells:pathCells];
}

- (void)_updateSymbolPathComponentCell; {
	NSMutableArray *pathCells = [[[[self jumpBar] pathComponentCells] mutableCopy] autorelease];	
	NSArray *symbols = [[[self jumpBarDataSource] sourceScanner] symbols];
	WCJumpBarComponentCell *symbolCell;
	
	if ([symbols count]) {
		WCSourceSymbol *symbol = [symbols sourceSymbolForRange:[[self textView] selectedRange]];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:WCReallyAdvancedJumpBarShowFileAndLineNumberKey])
			symbolCell = [[[WCJumpBarComponentCell alloc] initTextCell:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (line %lu)", @"jump bar symbols menu format string"),[symbol name],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]] autorelease];
		else
			symbolCell = [[[WCJumpBarComponentCell alloc] initTextCell:[symbol name]] autorelease];
		
		[symbolCell setImage:[symbol icon]];
		[symbolCell setRepresentedObject:symbol];
	}
	else {
		symbolCell = [[[WCJumpBarComponentCell alloc] initTextCell:NSLocalizedString(@"No Symbols", @"No Symbols")] autorelease];
	}
	
	[pathCells removeLastObject];
	[pathCells addObject:symbolCell];
	
	[[self jumpBar] setPathComponentCells:pathCells];
}

- (void)_updateTextViewSelectedLineAndColumn; {
	NSRange selectedRange = [[self textView] selectedRange];
	NSRange lineRange = [[[self textView] string] lineRangeForRange:selectedRange];
	NSUInteger lineNumber = [[[self textView] string] lineNumberForRange:selectedRange];
	
	if (selectedRange.length)
		[self setTextViewSelectedLineAndColumn:[NSString stringWithFormat:NSLocalizedString(@"%lu:%lu (%lu)", @"text view selected line and column format string"),++lineNumber,selectedRange.location-lineRange.location,selectedRange.length]];
	else
		[self setTextViewSelectedLineAndColumn:[NSString stringWithFormat:NSLocalizedString(@"%lu:%lu", @"text view selected line and column format string"),++lineNumber,selectedRange.location-lineRange.location]];
}

- (void)_showMenuForPathComponentCell:(NSPathComponentCell *)clickedCell {
	if ([[clickedCell representedObject] isKindOfClass:[WCSourceSymbol class]]) {
		NSArray *symbols = [[[self jumpBarDataSource] sourceScanner] symbols];
		
		if (![symbols count])
			return;
		
		NSUInteger numberOfSymbols = [symbols count];
		NSUInteger numberOfItems = [[self symbolsMenu] numberOfItems];
		// add items until we have the required amount
		if (numberOfItems < numberOfSymbols) {
			while (numberOfItems++ < numberOfSymbols)
				[[self symbolsMenu] addItem:[[[NSMenuItem alloc] init] autorelease]];
		}
		// remove items until we have the required amount
		else if (numberOfItems > numberOfSymbols) {
			while (numberOfItems-- > numberOfSymbols)
				[[self symbolsMenu] removeItemAtIndex:0];
		}
		
		NSUInteger selectedSymbolIndex = [symbols sourceSymbolIndexForRange:[[self textView] selectedRange]];
		WCSourceSymbol *selectedSymbol = [symbols objectAtIndex:selectedSymbolIndex];
		
		// show the symbols sorted by location
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:WCReallyAdvancedJumpBarSortItemsByKey] unsignedIntegerValue] == WCReallyAdvancedJumpBarSortItemsByLocation) {
			// command key indicates we should sort using the opposite behavior, in this case, sort by name
			if ([NSEvent isOnlyCommandKeyPressed]) {
				symbols = [[[self jumpBarDataSource] sourceScanner] symbolsSortedByName];
				[self _updateSymbolsMenuItemsWithSymbols:symbols selectedSymbol:selectedSymbol selectedSymbolIndex:&selectedSymbolIndex sortedByName:YES];
			}
			// sort normally by location
			else {
				[self _updateSymbolsMenuItemsWithSymbols:symbols selectedSymbol:selectedSymbol selectedSymbolIndex:&selectedSymbolIndex sortedByName:NO];
			}
		}
		// otherwise show the symbols sorted by name
		else {
			// command key indicates we should sort using the opposite behavior, in this case, sort by location
			if ([NSEvent isOnlyCommandKeyPressed]) {
				[self _updateSymbolsMenuItemsWithSymbols:symbols selectedSymbol:selectedSymbol selectedSymbolIndex:&selectedSymbolIndex sortedByName:NO];
			}
			// sort normally by name
			else {
				symbols = [[[self jumpBarDataSource] sourceScanner] symbolsSortedByName];
				[self _updateSymbolsMenuItemsWithSymbols:symbols selectedSymbol:selectedSymbol selectedSymbolIndex:&selectedSymbolIndex sortedByName:YES];
			}
		}
		
		NSRect cellRect = [[[self jumpBar] cell] rectOfPathComponentCell:clickedCell withFrame:[[self jumpBar] bounds] inView:[self jumpBar]];
		
		if (![[self symbolsMenu] popUpMenuPositioningItem:[[self symbolsMenu] itemAtIndex:selectedSymbolIndex] atLocation:cellRect.origin inView:[self jumpBar]])
			[[self jumpBar] setNeedsDisplay:YES];
	}
	else if ([[clickedCell representedObject] isKindOfClass:[WCFile class]]) {
		NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
		[menu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
		[menu setDelegate:self];
		[self setFilesMenu:menu];
		
		WCFileContainer *fileContainer = [[[self jumpBarDataSource] projectDocument] fileContainerForFile:[clickedCell representedObject]];
		NSArray *childNodes = ([fileContainer parentNode])?[[fileContainer parentNode] childNodes]:[NSArray arrayWithObject:fileContainer];
		for (WCFileContainer *child in childNodes) {
			NSMenuItem *item = [menu addItemWithTitle:[[child representedObject] fileName] action:@selector(_filesMenuItemClicked:) keyEquivalent:@""];
			
			[item setTarget:self];
			[item setImage:[[child representedObject] fileIcon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:[child representedObject]];
			
			if (fileContainer == child)
				[item setState:NSOnState];
			
			if (![child isLeafNode]) {
				NSMenu *submenu = [[[NSMenu alloc] initWithTitle:[item title]] autorelease];
				[submenu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
				[submenu setDelegate:self];
				
				[item setSubmenu:submenu];
			}
		}
		
		NSRect cellRect = [[[self jumpBar] cell] rectOfPathComponentCell:clickedCell withFrame:[[self jumpBar] bounds] inView:[self jumpBar]];
		
		if (![menu popUpMenuPositioningItem:[menu itemAtIndex:[menu indexOfItemWithRepresentedObject:[fileContainer representedObject]]] atLocation:cellRect.origin inView:[self jumpBar]])
			[[self jumpBar] setNeedsDisplay:YES];
	}
}

- (void)_updateSymbolsMenuItemsWithSymbols:(NSArray *)symbols selectedSymbol:(WCSourceSymbol *)selectedSymbol selectedSymbolIndex:(NSUInteger *)selectedSymbolIndex sortedByName:(BOOL)sortedByName; {
	BOOL showFileAndLineNumber = [[NSUserDefaults standardUserDefaults] boolForKey:WCReallyAdvancedJumpBarShowFileAndLineNumberKey];
	NSUInteger symbolIndex, numberOfSymbols = [symbols count];
	
	if (sortedByName) {
		for (symbolIndex = 0; symbolIndex < numberOfSymbols; symbolIndex++) {
			WCSourceSymbol *symbol = [symbols objectAtIndex:symbolIndex];
			NSMenuItem *item = [[self symbolsMenu] itemAtIndex:symbolIndex];
			
			[item setTarget:self];
			[item setAction:@selector(_symbolsMenuClick:)];
			if (showFileAndLineNumber)
				[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (line %lu)", @"jump bar symbols menu format string"),[symbol name],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]];
			else
				[item setTitle:[symbol name]];
			[item setImage:[symbol icon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:symbol];
			
			if (symbol == selectedSymbol) {
				*selectedSymbolIndex = symbolIndex;
				[item setState:NSOnState];
			}
			else
				[item setState:NSOffState];
		}
	}
	else {
		for (symbolIndex = 0; symbolIndex < numberOfSymbols; symbolIndex++) {
			WCSourceSymbol *symbol = [symbols objectAtIndex:symbolIndex];
			NSMenuItem *item = [[self symbolsMenu] itemAtIndex:symbolIndex];
			
			[item setTarget:self];
			[item setAction:@selector(_symbolsMenuClick:)];
			if (showFileAndLineNumber)
				[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (line %lu)", @"jump bar symbols menu format string"),[symbol name],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]];
			else
				[item setTitle:[symbol name]];
			[item setImage:[symbol icon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:symbol];
			[item setState:(symbolIndex == *selectedSymbolIndex)?NSOnState:NSOffState];
		}
	}
}
#pragma mark IBActions
- (IBAction)_jumpBarClicked:(id)sender {
	NSPathComponentCell *clickedCell = [[self jumpBar] clickedPathComponentCell];
	
	[self _showMenuForPathComponentCell:clickedCell];
}

- (IBAction)_symbolsMenuClick:(id)sender; {
	[[self textView] setSelectedRange:[[sender representedObject] range]];
	[[self textView] scrollRangeToVisible:[[sender representedObject] range]];
}

- (IBAction)_recentFilesMenuItemClicked:(id)sender {
	[[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[sender representedObject] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
		
	}];
}
- (IBAction)_includesMenuItemClicked:(id)sender {
	[[[self jumpBarDataSource] projectDocument] openTabForFile:[sender representedObject] tabViewContext:nil];
}
- (IBAction)_filesMenuItemClicked:(id)sender {
	[[[self jumpBarDataSource] projectDocument] openTabForFile:[sender representedObject] tabViewContext:nil];
}
- (IBAction)_unsavedFilesMenuItemClicked:(id)sender {
	[[[self jumpBarDataSource] projectDocument] openTabForFile:[sender representedObject] tabViewContext:nil];
}
#pragma mark Notifications
- (void)_textViewDidChangeSelection:(NSNotification *)note {
	[self _updateSymbolPathComponentCell];
	[self _updateTextViewSelectedLineAndColumn];
}

- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {	
	[self _updateSymbolPathComponentCell];
}
- (void)_projectNavigatorDidGroupNodes:(NSNotification *)note {	
	WCFile *file = [[[[self jumpBarDataSource] projectDocument] sourceFileDocumentsToFiles] objectForKey:[[self jumpBarDataSource] sourceFileDocument]];
	WCFileContainer *fileContainer = [[[self jumpBarDataSource] projectDocument] fileContainerForFile:file];
	NSSet *groupedNodes = [[note userInfo] objectForKey:WCProjectNavigatorDidGroupNodesNotificationGroupedNodesUserInfoKey];
	
	if ([groupedNodes containsObject:fileContainer]) {
		[self _updatePathComponentCells];
		[self _updateSymbolPathComponentCell];
	}
}
- (void)_projectNavigatorDidUngroupNodes:(NSNotification *)note {
	WCFile *file = [[[[self jumpBarDataSource] projectDocument] sourceFileDocumentsToFiles] objectForKey:[[self jumpBarDataSource] sourceFileDocument]];
	WCFileContainer *fileContainer = [[[self jumpBarDataSource] projectDocument] fileContainerForFile:file];
	NSSet *ungroupedNodes = [[note userInfo] objectForKey:WCProjectNavigatorDidUngroupNodesNotificationUngroupedNodesUserInfoKey];
	
	if ([ungroupedNodes containsObject:fileContainer]) {
		[self _updatePathComponentCells];
		[self _updateSymbolPathComponentCell];
	}
}
- (void)_projectNavigatorDidRenameNode:(NSNotification *)note {
	WCFileContainer *fileContainer = [[note userInfo] objectForKey:WCProjectNavigatorDidRenameNodeNotificationRenamedNodeUserInfoKey];
	
	if ([[[[self jumpBar] pathComponentCells] valueForKey:@"representedObject"] containsObject:[fileContainer representedObject]]) {
		[self _updatePathComponentCells];
		[self _updateSymbolPathComponentCell];
	}
}
- (void)_projectNavigatorDidMoveNodes:(NSNotification *)note {
	WCFile *file = [[[[self jumpBarDataSource] projectDocument] sourceFileDocumentsToFiles] objectForKey:[[self jumpBarDataSource] sourceFileDocument]];
	WCFileContainer *fileContainer = [[[self jumpBarDataSource] projectDocument] fileContainerForFile:file];
	NSSet *movedNodes = [[note userInfo] objectForKey:WCProjectNavigatorDidMoveNodesNotificationMovedNodesUserInfoKey];
	
	if ([movedNodes containsObject:fileContainer]) {
		[self _updatePathComponentCells];
		[self _updateSymbolPathComponentCell];
	}
}
@end
