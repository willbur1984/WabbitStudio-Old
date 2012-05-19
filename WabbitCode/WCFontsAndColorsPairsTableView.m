//
//  WCFontsAndColorsPairsTableView.m
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCFontsAndColorsPairsTableView.h"

@interface WCFontsAndColorsPairsTableView ()
@property (readwrite,retain,nonatomic) NSColor *selectionColor;
@end

@implementation WCFontsAndColorsPairsTableView
#pragma mark *** Subclass Overrides ***
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
#pragma mark *** Public Methods ***

#pragma mark Properties
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
