//
//  WCRoundedBorderTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCRoundedBorderTextFieldCell.h"
#import "RSDefines.h"
#import "RSVerticallyCenteredTextFieldCell.h"

@implementation WCRoundedBorderTextFieldCell

- (void)dealloc {
	[_titleCell release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	_titleCell = [[RSVerticallyCenteredTextFieldCell alloc] initTextCell:@""];
	[_titleCell setAlignment:[self alignment]];
	[_titleCell setFont:[self font]];
	
	return self;
}

static const CGFloat kRoundedBorderLeftRightPadding = 8.0;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if ([[self textColor] isEqual:[NSColor alternateSelectedControlTextColor]]) {
		NSSize cellSize = [self cellSizeForBounds:cellFrame];
		cellSize.width += kRoundedBorderLeftRightPadding;
		NSRect centerRect = NSCenteredRectWithSize(cellSize, cellFrame);
		//centerRect.origin.y = NSMinY(cellFrame);
		
		if ([[controlView window] isKeyWindow] && [[[controlView window] firstResponder] isKindOfClass:[NSCollectionView class]]) {
			[[NSColor alternateSelectedControlColor] setFill];
			[_titleCell setTextColor:[NSColor alternateSelectedControlTextColor]];
		}
		else {
			[[NSColor secondarySelectedControlColor] setFill];
			[_titleCell setTextColor:[NSColor controlTextColor]];
		}
		
		[[NSBezierPath bezierPathWithRoundedRect:centerRect xRadius:8.0 yRadius:8.0] fill];
	}
	else
		[_titleCell setTextColor:[NSColor controlTextColor]];
	
	[_titleCell setStringValue:[self stringValue]];
	[_titleCell drawInteriorWithFrame:cellFrame inView:controlView];
}
@end
