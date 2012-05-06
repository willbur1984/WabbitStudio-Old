//
//  WCRoundedBorderTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCRoundedBorderTextFieldCell.h"
#import "RSDefines.h"
#import "WCRoundedBorderTextField.h"

@implementation WCRoundedBorderTextFieldCell
#pragma mark *** Subclass Overrides ***
static const CGFloat kRoundedBorderLeftRightPadding = 8.0;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	WCRoundedBorderTextField *textField = (WCRoundedBorderTextField *)controlView;
	
	if ([[textField collectionViewItem] isSelected]) {
		NSSize cellSize = [self cellSizeForBounds:cellFrame];
		cellSize.width += kRoundedBorderLeftRightPadding;
		NSRect centerRect = NSCenteredRectWithSize(cellSize, cellFrame);
		
		if ([[controlView window] isKeyWindow] && [[[controlView window] firstResponder] isKindOfClass:[NSCollectionView class]]) {
			[[NSColor alternateSelectedControlColor] setFill];
			[self setTextColor:[NSColor alternateSelectedControlTextColor]];
		}
		else {
			[[NSColor secondarySelectedControlColor] setFill];
			[self setTextColor:[NSColor controlTextColor]];
		}
		
		[[NSBezierPath bezierPathWithRoundedRect:centerRect xRadius:8.0 yRadius:8.0] fill];
	}
	else
		[self setTextColor:[NSColor controlTextColor]];
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}
@end
