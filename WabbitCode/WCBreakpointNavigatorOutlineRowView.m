//
//  WCBreakpointNavigatorOutlineRowView.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointNavigatorOutlineRowView.h"
#import "RSTreeNode.h"
#import "NSTreeController+RSExtensions.h"

@implementation WCBreakpointNavigatorOutlineRowView
#pragma mark *** Subclass Overrides ***
- (void)drawBackgroundInRect:(NSRect)dirtyRect {
	RSTreeNode *result = [[self viewAtColumn:0] objectValue];
	
	if (![result isLeafNode]) {
		[super drawBackgroundInRect:dirtyRect];
		if (![result parentNode])
			return;
		
		NSOutlineView *ov = [self outlineView];
		
		if ([ov isItemExpanded:[(NSTreeController *)[ov dataSource] treeNodeForRepresentedObject:result]]) {
			[[NSColor gridColor] setFill];
			NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMaxY([self bounds])-1.0, NSWidth([self bounds]), 1.0));
		}
		return;
	}
	
	[[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] setFill];
	NSRectFill([self bounds]);
	
	if ([[[result parentNode] childNodes] lastObject] == result) {
		[[NSColor gridColor] setFill];
		NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMaxY([self bounds])-1.0, NSWidth([self bounds]), 1.0));
	}
}

@synthesize outlineView=_outlineView;
@end
