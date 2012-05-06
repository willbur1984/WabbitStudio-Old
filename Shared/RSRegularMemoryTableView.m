//
//  RSRegularMemoryTableView.m
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

#import "RSRegularMemoryTableView.h"
#import "RSRegularMemoryViewController.h"
#import "RSCalculator.h"
#import "RSDefines.h"

@implementation RSRegularMemoryTableView

+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Jump to Address", @"Jump to Address") action:@selector(jumpToAddress:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Jump to Program Counter", @"Jump to Program Counter") action:@selector(jumpToProgramCounter:) keyEquivalent:@""];
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
	BOOL isFirstResponder = ([[self window] isKeyWindow] &&
							 ([[self window] firstResponder] == self || [self editedRow] != -1));
	NSUInteger numberOfMemoryColumns = [[self tableColumns] count] - 1;
	uint16_t programCounter = [[[self regularMemoryViewController] calculator] programCounter];
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSRange rowRange = [self rowsInRect:clipRect];
	NSUInteger rowIndex;
	
	for (rowIndex=rowRange.location; rowIndex<NSMaxRange(rowRange); rowIndex++) {
		uint16_t address = 0;
		
		address += (rowIndex * numberOfMemoryColumns);
		
		if ([selectedRowIndexes containsIndex:rowIndex]) {			
			NSRect rowRect = [self rectOfRow:rowIndex];
			rowRect.size.height -= floor([self intercellSpacing].height/2.0);
			
			if (NSLocationInRange(programCounter, NSMakeRange(address, numberOfMemoryColumns))) {
				if ([[[self regularMemoryViewController] calculator] CPUHalt]) {
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
		else if (NSLocationInRange(programCounter, NSMakeRange(address, numberOfMemoryColumns))) {
			NSRect rowRect = [self rectOfRow:rowIndex];
			rowRect.size.height -= floor([self intercellSpacing].height/2.0);
			
			if ([[[self regularMemoryViewController] calculator] CPUHalt])
				[programCounterHaltGradient drawInRect:rowRect angle:180.0];
			else
				[programCounterGradient drawInRect:rowRect angle:180.0];
		}
	}
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Debug Session", @"No Debug Session");
}

@synthesize regularMemoryViewController=_regularMemoryViewController;

@end
