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
#import "NSString+WCExtensions.h"
#import "NSEvent+RSExtensions.h"
#import "NSAttributedString+WCExtensions.h"
#import "WCReallyAdvancedViewController.h"
#import "NSObject+WCExtensions.h"
#import "NSImage+RSExtensions.h"

@interface WCJumpBarViewController ()
@property (readwrite,copy,nonatomic) NSString *textViewSelectedLineAndColumn;
@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,nonatomic) NSMenu *symbolsMenu;
@property (readonly,nonatomic) id <WCJumpBarDataSource> jumpBarDataSource;

- (void)_updatePathComponentCells;
- (void)_updateFilePathComponentCell;
- (void)_updateSymbolPathComponentCell;
- (void)_updateTextViewSelectedLineAndColumn;
- (void)_updateSymbolsMenuItemsWithSymbols:(NSArray *)symbols selectedSymbol:(WCSourceSymbol *)selectedSymbol selectedSymbolIndex:(NSUInteger *)selectedSymbolIndex sortedByName:(BOOL)sortedByName;
@end

@implementation WCJumpBarViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanUpUserDefaultsObserving];
	_textView = nil;
	_jumpBarDataSource = nil;
	[_symbolsMenu release];
	[_textViewSelectedLineAndColumn release];
	[super dealloc];
}

- (id)initWithTextView:(NSTextView *)textView jumpBarDataSource:(id <WCJumpBarDataSource>)jumpBarDataSource; {
	if (!(self = [super initWithNibName:@"WCJumpBarView" bundle:nil]))
		return nil;
	
	_textView = textView;
	_jumpBarDataSource = jumpBarDataSource;
	_symbolsMenu = [[NSMenu alloc] initWithTitle:@""];
	[_symbolsMenu setDelegate:self];
	[_symbolsMenu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	
	[self setTextViewSelectedLineAndColumn:NSLocalizedString(@"1:0", @"1:0")];
	
	[self setupUserDefaultsObserving];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:textView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:[jumpBarDataSource sourceScanner]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:[[jumpBarDataSource document] undoManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:[[jumpBarDataSource document] undoManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_undoManagerDidCloseUndoGroup:) name:NSUndoManagerDidCloseUndoGroupNotification object:[[jumpBarDataSource document] undoManager]];
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	[[self jumpBar] setTarget:self];
	[[self jumpBar] setAction:@selector(_jumpBarClicked:)];
	
	[self _updatePathComponentCells];
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCReallyAdvancedJumpBarShowFileAndLineNumberKey])
		return;
	else if (menu == [self symbolsMenu]) {
		if ([menu highlightedItem]) {
			NSMenuItem *oldItem = [menu highlightedItem];
			
			[oldItem setTitle:[[oldItem representedObject] name]];
		}
		
		if (item) {
			WCSourceSymbol *symbol = [item representedObject];
			
			[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (%@:%lu)", @"jump bar symbols menu format string"),[symbol name],[[self jumpBarDataSource] displayName],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCReallyAdvancedJumpBarShowFileAndLineNumberKey]]) {
		[self _updateSymbolPathComponentCell];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSSet *)userDefaultsKeyPathsToObserve {
	return [NSSet setWithObjects:WCReallyAdvancedJumpBarShowFileAndLineNumberKey, nil];
}

@synthesize jumpBar=_jumpBar;
@synthesize jumpBarDataSource=_jumpBarDataSource;
@synthesize textView=_textView;

@synthesize textViewSelectedLineAndColumn=_textViewSelectedLineAndColumn;
@synthesize symbolsMenu=_symbolsMenu;

- (void)_updatePathComponentCells; {
	if (![self jumpBarDataSource])
		return;
	
	NSMutableArray *pathCells = [NSMutableArray arrayWithCapacity:0];
	
	if ([[self jumpBarDataSource] fileURL]) {
		WCJumpBarComponentCell *fileCell = [[[WCJumpBarComponentCell alloc] initTextCell:[[self jumpBarDataSource] displayName]] autorelease];
		
		[fileCell setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[[self jumpBarDataSource] fileURL] path]]];
		
		[pathCells addObject:fileCell];
	}
	else {
		WCJumpBarComponentCell *fileCell = [[[WCJumpBarComponentCell alloc] initTextCell:[[self jumpBarDataSource] displayName]] autorelease];
		
		[fileCell setImage:[NSImage imageNamed:@"UntitledFile"]];
		
		[pathCells addObject:fileCell];
	}
	
	[pathCells addObject:[[[WCJumpBarComponentCell alloc] initTextCell:NSLocalizedString(@"No Symbols", @"No Symbols")] autorelease]];
	
	[[self jumpBar] setPathComponentCells:pathCells];
}

- (void)_updateFilePathComponentCell; {
	NSMutableArray *pathCells = [[[[self jumpBar] pathComponentCells] mutableCopy] autorelease];
	NSImage *fileIcon;
	
	if ([[self jumpBarDataSource] fileURL])
		fileIcon = [[NSWorkspace sharedWorkspace] iconForFile:[[[self jumpBarDataSource] fileURL] path]];
	else
		fileIcon = [NSImage imageNamed:@"UntitledFile"];
	
	if ([[[self jumpBarDataSource] document] isDocumentEdited])
		fileIcon = [fileIcon unsavedImageFromImage];
	
	WCJumpBarComponentCell *fileCell = [[[WCJumpBarComponentCell alloc] initTextCell:[[self jumpBarDataSource] displayName]] autorelease];
	[fileCell setImage:fileIcon];
	
	[pathCells replaceObjectAtIndex:[pathCells count]-2 withObject:fileCell];
	
	[[self jumpBar] setPathComponentCells:pathCells];
}

- (void)_updateSymbolPathComponentCell; {
	NSMutableArray *pathCells = [[[[self jumpBar] pathComponentCells] mutableCopy] autorelease];	
	NSArray *symbols = [[[self jumpBarDataSource] sourceScanner] symbols];
	WCJumpBarComponentCell *symbolCell;
	
	if ([symbols count]) {
		WCSourceSymbol *symbol = [symbols sourceSymbolForRange:[[self textView] selectedRange]];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:WCReallyAdvancedJumpBarShowFileAndLineNumberKey])
			symbolCell = [[[WCJumpBarComponentCell alloc] initTextCell:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (%@:%lu)", @"jump bar symbols menu format string"),[symbol name],[[self jumpBarDataSource] displayName],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]] autorelease];
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
	
	[self setTextViewSelectedLineAndColumn:[NSString stringWithFormat:NSLocalizedString(@"%lu:%lu", @"text view selected line and column format string"),++lineNumber,selectedRange.location-lineRange.location]];
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
				[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (%@:%lu)", @"jump bar symbols menu format string"),[symbol name],[[self jumpBarDataSource] displayName],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]];
			else
				[item setTitle:[symbol name]];
			[item setImage:[symbol icon]];
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
				[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 (%@:%lu)", @"jump bar symbols menu format string"),[symbol name],[[self jumpBarDataSource] displayName],[[[self textView] textStorage] lineNumberForRange:[symbol range]]+1]];
			else
				[item setTitle:[symbol name]];
			[item setImage:[symbol icon]];
			[item setRepresentedObject:symbol];
			[item setState:(symbolIndex == *selectedSymbolIndex)?NSOnState:NSOffState];
		}
	}
}

- (IBAction)_jumpBarClicked:(id)sender {
	NSPathComponentCell *clickedCell = [[self jumpBar] clickedPathComponentCell];
	
	if (![[clickedCell representedObject] isKindOfClass:[WCSourceSymbol class]])
		return;
	
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

- (IBAction)_symbolsMenuClick:(id)sender; {
	[[self textView] setSelectedRange:[[sender representedObject] range]];
	[[self textView] scrollRangeToVisible:[[self textView] selectedRange]];
}

- (void)_textViewDidChangeSelection:(NSNotification *)note {
	[self _updateSymbolPathComponentCell];
	[self _updateTextViewSelectedLineAndColumn];
}

- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {	
	[self _updateSymbolPathComponentCell];
}
- (void)_undoManagerDidRedo:(NSNotification *)note {
	[self _updateFilePathComponentCell];
}
- (void)_undoManagerDidUndo:(NSNotification *)note {
	[self _updateFilePathComponentCell];
}
- (void)_undoManagerDidCloseUndoGroup:(NSNotification *)note {
	[self _updateFilePathComponentCell];
}
@end
