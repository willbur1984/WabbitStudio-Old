//
//  RSRegularMemoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSRegularMemoryViewController.h"
#import "RSCalculator.h"
#import "RSHexadecimalFormatter.h"
#import "RSDefines.h"
#import "RSNoHighlightColorTextFieldCell.h"

@interface RSRegularMemoryViewController ()
@property (readwrite,assign,nonatomic) NSUInteger rowCount;

- (void)_updateMemoryTableColumns;
@end

@implementation RSRegularMemoryViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator removeObserver:self forKeyPath:@"debugging" context:self];
	[_calculator removeObserver:self forKeyPath:@"programCounter" context:self];
	[_calculator removeObserver:self forKeyPath:@"CPUHalt" context:self];
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSRegularMemoryView";
}

- (void)loadView {
	[super loadView];
	
	[[self memoryColumnFormatter] setHexadecimalFormat:RSHexadecimalFormatUnsignedChar];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[[[self tableView] enclosingScrollView] contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:[[[self tableView] enclosingScrollView] contentView]];
	
	[self _updateMemoryTableColumns];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == self) {
		if ([keyPath isEqualToString:@"programCounter"]) {
			[[self tableView] reloadData];
		}
		else if ([keyPath isEqualToString:@"CPUHalt"])
			[[self tableView] setNeedsDisplay:YES];
		else if ([keyPath isEqualToString:@"debugging"])
			[self _updateMemoryTableColumns];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [self rowCount];
}

static NSString *const kAddressColumnIdentifier = @"address";

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSUInteger numberOfMemoryColumns = [[[self tableView] tableColumns] count] - 1;
	uint16_t address = (row * numberOfMemoryColumns);
	
	if ([[tableColumn identifier] isEqualToString:kAddressColumnIdentifier])
		return [NSNumber numberWithUnsignedShort:address];
	
	NSUInteger offset = [[[self tableView] tableColumns] indexOfObjectIdenticalTo:tableColumn];
	waddr_t wideAddress = addr_to_waddr(&([[self calculator] calculator]->mem_c), (uint16_t)(address+offset));
	uint8_t data = wmem_read(&([[self calculator] calculator]->mem_c), wideAddress);
	
	return [NSNumber numberWithUnsignedChar:data];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSUInteger numberOfMemoryColumns = [[[self tableView] tableColumns] count] - 1;
	uint16_t address = (row * numberOfMemoryColumns);
	NSUInteger offset = [[[self tableView] tableColumns] indexOfObjectIdenticalTo:tableColumn];
	uint8_t data = [object unsignedCharValue];
	waddr_t wideAddress = addr_to_waddr(&([[self calculator] calculator]->mem_c), (uint16_t)(address+offset));
	
	mem_write(&([[self calculator] calculator]->mem_c), wideAddress.addr, data);
}

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
	if ([[tableColumn identifier] isEqualToString:kAddressColumnIdentifier])
		return nil;
	
	NSUInteger numberOfMemoryColumns = [[[self tableView] tableColumns] count] - 1;
	uint16_t address = (row * numberOfMemoryColumns);
	NSUInteger offset = [[[self tableView] tableColumns] indexOfObjectIdenticalTo:tableColumn];
	waddr_t wideAddress = addr_to_waddr(&([[self calculator] calculator]->mem_c), (uint16_t)(address+offset));
	uint8_t data = wmem_read(&([[self calculator] calculator]->mem_c), wideAddress);
	
	return [NSString stringWithFormat:NSLocalizedString(@"Address: %04X\nData: %02x", @"regular memory table view tooltip format string"),wideAddress.addr,data];
}

- (void)jumpToMemoryAddress:(uint16_t)memoryAddress; {
	NSUInteger numberOfMemoryColumns = [[[self tableView] tableColumns] count] - 1;
	NSUInteger rowIndex, numberOfRows = [self numberOfRowsInTableView:[self tableView]];
	uint16_t cmpAddress;
	
	for (rowIndex=0, cmpAddress=0; rowIndex<numberOfRows; rowIndex++, cmpAddress=(rowIndex*numberOfMemoryColumns)) {
		if (NSLocationInRange(memoryAddress, NSMakeRange(cmpAddress, numberOfMemoryColumns))) {
			[[self tableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
			[[self tableView] scrollRowToVisible:rowIndex];
			return;
		}
	}
	
	NSBeep();
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	[_calculator addObserver:self forKeyPath:@"programCounter" options:0 context:self];
	[_calculator addObserver:self forKeyPath:@"CPUHalt" options:0 context:self];
	[_calculator addObserver:self forKeyPath:@"debugging" options:0 context:self];
	
	return self;
}

@synthesize tableView=_tableView;
@synthesize memoryColumnFormatter=_memoryColumnFormatter;

@synthesize calculator=_calculator;
@synthesize rowCount=_rowCount;
- (void)setRowCount:(NSUInteger)rowCount {
	_rowCount = rowCount;
	
	[[self tableView] reloadData];
}

- (void)_updateMemoryTableColumns; {
	if (![[self calculator] isDebugging]) {
		while ([[[self tableView] tableColumns] count] > 1)
			[[self tableView] removeTableColumn:[[[self tableView] tableColumns] lastObject]];
		
		[self setRowCount:0];
		return;
	}
	
	static const CGFloat kMemoryColumnWidth = 25.0;
	const CGFloat columnPadding = [[self tableView] intercellSpacing].width;
	CGFloat addressColumnWidth = [[[[self tableView] tableColumns] objectAtIndex:0] width] + columnPadding;
	CGFloat memoryColumnWidth = kMemoryColumnWidth + columnPadding;
	CGFloat availableWidth = NSWidth([[self tableView] visibleRect]) - addressColumnWidth;
	NSUInteger numberOfMemoryColumns = [[[self tableView] tableColumns] count] - 1;
	NSUInteger maxNumberOfMemoryColumns = (NSUInteger)floor(availableWidth/memoryColumnWidth);
	NSUInteger numberOfRows = (UINT16_MAX/maxNumberOfMemoryColumns) + 1;
	
	if (numberOfMemoryColumns < maxNumberOfMemoryColumns) {
		static RSNoHighlightColorTextFieldCell *memoryColumnTextFieldCell;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			memoryColumnTextFieldCell = [[RSNoHighlightColorTextFieldCell alloc] initTextCell:@""];
			
			[memoryColumnTextFieldCell setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
			[memoryColumnTextFieldCell setEditable:YES];
			[memoryColumnTextFieldCell setFormatter:[self memoryColumnFormatter]];
		});
		
		while (numberOfMemoryColumns++ < maxNumberOfMemoryColumns) {			
			NSTableColumn *tableColumn = [[[NSTableColumn alloc] initWithIdentifier:@""] autorelease];
			
			[tableColumn setDataCell:memoryColumnTextFieldCell];
			
			[[tableColumn headerCell] setTitle:NSLocalizedString(@"Memory", @"Memory")];
			[tableColumn setWidth:kMemoryColumnWidth];
			[tableColumn setResizingMask:NSTableColumnNoResizing];
			[tableColumn setEditable:YES];
			
			[[self tableView] addTableColumn:tableColumn];
		}
	}
	else if (numberOfMemoryColumns > maxNumberOfMemoryColumns) {
		while (numberOfMemoryColumns-- > maxNumberOfMemoryColumns)
			[[self tableView] removeTableColumn:[[[self tableView] tableColumns] lastObject]];
	}
	
	[self setRowCount:numberOfRows];
}

- (void)_viewBoundsDidChange:(NSNotification *)note {
	[self _updateMemoryTableColumns];
}

- (void)_viewFrameDidChange:(NSNotification *)note {
	[self _updateMemoryTableColumns];
}

@end
