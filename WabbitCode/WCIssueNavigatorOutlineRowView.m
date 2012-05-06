//
//  WCIssueNavigatorOutlineRowView.m
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCIssueNavigatorOutlineRowView.h"
#import "RSTreeNode.h"
#import "NSTreeController+RSExtensions.h"

@implementation WCIssueNavigatorOutlineRowView
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
