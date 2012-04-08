//
//  WCRoundedBorderTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
