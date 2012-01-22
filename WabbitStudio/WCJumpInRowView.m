//
//  WCJumpInRowView.m
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpInRowView.h"

@implementation WCJumpInRowView
#pragma mark *** Subclass Overrides ***
- (void)drawSelectionInRect:(NSRect)dirtyRect {
	//[super drawSelectionInRect:dirtyRect];
	
	[[NSColor alternateSelectedControlColor] setFill];
	NSRectFill(dirtyRect);
}

- (NSBackgroundStyle)interiorBackgroundStyle {
	return ([self isSelected])?NSBackgroundStyleDark:NSBackgroundStyleLight;
}
@end
