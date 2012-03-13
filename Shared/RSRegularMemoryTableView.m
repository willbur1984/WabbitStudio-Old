//
//  RSRegularMemoryTableView.m
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSRegularMemoryTableView.h"
#import "RSRegularMemoryViewController.h"
#import "RSCalculator.h"
#import "RSDefines.h"

@implementation RSRegularMemoryTableView

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
