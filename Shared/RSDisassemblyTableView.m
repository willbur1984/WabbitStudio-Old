//
//  RSDisassemblyTableView.m
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSDisassemblyTableView.h"
#import "NSBezierPath+StrokeExtensions.h"

@implementation RSDisassemblyTableView

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	BOOL isFirstResponder = ([[self window] isKeyWindow] && [[self window] firstResponder] == self);
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSRange rowsInRect = [self rowsInRect:clipRect];
	NSUInteger rowIndex;
	
	for (rowIndex=rowsInRect.location; rowIndex<NSMaxRange(rowsInRect); rowIndex++) {
		if (![selectedRowIndexes containsIndex:rowIndex])
			continue;
		
		NSRect rowRect = [self rectOfRow:rowIndex];
		rowRect.size.height -= floor([self intercellSpacing].height/2.0);
		
		if (isFirstResponder)
			[[NSColor alternateSelectedControlColor] setFill];
		else
			[[NSColor secondarySelectedControlColor] setFill];
		
		NSRectFill(rowRect);
	}
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Debug Session", @"No Debug Session");
}

@end
