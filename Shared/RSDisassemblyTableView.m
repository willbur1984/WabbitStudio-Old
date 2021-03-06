//
//  RSDisassemblyTableView.m
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSDisassemblyTableView.h"
#import "RSCalculator.h"
#import "RSDisassemblyViewController.h"

@implementation RSDisassemblyTableView

+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Jump to Address", @"Jump to Address") action:@selector(jumpToAddress:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Jump to Program Counter", @"Jump to Program Counter") action:@selector(jumpToProgramCounter:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Breakpoint", @"Breakpoint") action:NULL keyEquivalent:@""];
		
		NSMenu *breakpointMenu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
		
		[breakpointMenu addItemWithTitle:NSLocalizedString(@"Normal", @"Normal") action:@selector(toggleNormalBreakpoint:) keyEquivalent:@""];
		[breakpointMenu addItemWithTitle:NSLocalizedString(@"Read", @"Read") action:@selector(toggleReadBreakpoint:) keyEquivalent:@""];
		[breakpointMenu addItemWithTitle:NSLocalizedString(@"Write", @"Write") action:@selector(toggleWriteBreakpoint:) keyEquivalent:@""];
		
		[[[retval itemArray] lastObject] setSubmenu:breakpointMenu];
	});
	return retval;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	NSColor *programCounterColor = [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.0 alpha:1.0];
	NSColor *programCounterHaltColor = [NSColor orangeColor];
	//NSColor *breakpointColor = [NSColor colorWithCalibratedRed:0.95 green:0.0 blue:0.0 alpha:1.0];
	NSGradient *selectedProgramCounterFirstResponderGradient = [[[NSGradient alloc] initWithStartingColor:programCounterColor endingColor:[NSColor alternateSelectedControlColor]] autorelease];
	NSGradient *selectedProgramCounterHaltFirstResponderGradient = [[[NSGradient alloc] initWithStartingColor:programCounterHaltColor endingColor:[NSColor alternateSelectedControlColor]] autorelease];
	NSGradient *selectedProgramCounterGradient = [[[NSGradient alloc] initWithStartingColor:programCounterColor endingColor:[NSColor secondarySelectedControlColor]] autorelease];
	NSGradient *selectedProgramCounterHaltGradient = [[[NSGradient alloc] initWithStartingColor:programCounterHaltColor endingColor:[NSColor secondarySelectedControlColor]] autorelease];
	NSGradient *programCounterGradient = [[[NSGradient alloc] initWithStartingColor:programCounterColor endingColor:[self backgroundColor]] autorelease];
	NSGradient *programCounterHaltGradient = [[[NSGradient alloc] initWithStartingColor:programCounterHaltColor endingColor:[self backgroundColor]] autorelease];
	Z80_info_t *infos = [[self disassemblyViewController] Z80_infos];
	uint16_t programCounter = [[[self disassemblyViewController] calculator] programCounter];
	BOOL isFirstResponder = ([[self window] isKeyWindow] && [[self window] firstResponder] == self);
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSRange rowsInRect = [self rowsInRect:clipRect];
	NSUInteger rowIndex;
	
	for (rowIndex=rowsInRect.location; rowIndex<NSMaxRange(rowsInRect); rowIndex++) {
		Z80_info_t info = infos[rowIndex];
		
		if ([selectedRowIndexes containsIndex:rowIndex]) {
			NSRect rowRect = [self rectOfRow:rowIndex];
			
			rowRect.size.height -= floor([self intercellSpacing].height/2.0);
			
			if (info.waddr.addr == programCounter) {
				if ([[[self disassemblyViewController] calculator] CPUHalt]) {
					if (isFirstResponder)
						[selectedProgramCounterHaltFirstResponderGradient drawInRect:rowRect angle:180.0];
					else
						[selectedProgramCounterHaltGradient drawInRect:rowRect angle:180.0];
				}
				else {
					if (isFirstResponder)
						[selectedProgramCounterFirstResponderGradient drawInRect:rowRect angle:180.0];
					else
						[selectedProgramCounterGradient drawInRect:rowRect angle:180.0];
				}
			}
			else {
				if (isFirstResponder)
					[[NSColor alternateSelectedControlColor] setFill];
				else
					[[NSColor secondarySelectedControlColor] setFill];
				
				NSRectFill(rowRect);
			}
		}
		else if (info.waddr.addr == programCounter) {
			NSRect rowRect = [self rectOfRow:rowIndex];
			
			rowRect.size.height -= floor([self intercellSpacing].height/2.0);
			
			if ([[[self disassemblyViewController] calculator] CPUHalt])
				[programCounterHaltGradient drawInRect:rowRect angle:180.0];
			else
				[programCounterGradient drawInRect:rowRect angle:180.0];
		}
	}
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Debug Session", @"No Debug Session");
}

@synthesize disassemblyViewController=_disassemblyViewController;

@end
