//
//  WCFontsAndColorsPairsTableView.m
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFontsAndColorsPairsTableView.h"

@interface WCFontsAndColorsPairsTableView ()
@property (readwrite,retain,nonatomic) NSColor *selectionColor;
@end

@implementation WCFontsAndColorsPairsTableView
- (void)dealloc {
	[_selectionColor release];
	[super dealloc];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self bind:@"selectionColor" toObject:[self themesArrayController] withKeyPath:@"selection.selectionColor" options:nil];
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSRange rowRange = [self rowsInRect:clipRect];
	NSUInteger rowIndex;
	
	for (rowIndex = rowRange.location; rowIndex < NSMaxRange(rowRange); rowIndex++) {
		if ([selectedRowIndexes containsIndex:rowIndex]) {
			NSRect rowRect = [self rectOfRow:rowIndex];
			rowRect.size.height -= floor([self intercellSpacing].height/2.0);
			
			[[self selectionColor] setFill];
			NSRectFill(rowRect);
		}
	}
}

@synthesize themesArrayController=_themesArrayController;
@dynamic selectionColor;
- (NSColor *)selectionColor {
	return _selectionColor;
}
- (void)setSelectionColor:(NSColor *)selectionColor {
	if (_selectionColor == selectionColor)
		return;
	
	[_selectionColor release];
	_selectionColor = [selectionColor retain];
	
	[self setNeedsDisplay:YES];
}
@end
