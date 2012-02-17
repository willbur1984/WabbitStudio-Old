//
//  WCSourceScroller.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceScroller.h"
#import "WCBuildIssue.h"
#import "RSDefines.h"

@implementation WCSourceScroller
- (void)dealloc {
	[_buildIssues release];
	[super dealloc];
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
	[super drawKnobSlotInRect:slotRect highlight:flag];
	
	if ([[self buildIssues] count]) {
		NSTextView *textView = (NSTextView *)[[self scrollView] documentView];
		NSLayoutManager *layoutManager = [textView layoutManager];
		CGFloat yScale = NSHeight([textView frame])/NSHeight(slotRect);
		
		for (WCBuildIssue *buildIssue in [self buildIssues]) {
			NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:[buildIssue range].location] effectiveRange:NULL];
			
			if ([buildIssue type] == WCBuildIssueTypeError)
				[[NSColor redColor] setFill];
			else if ([buildIssue type] == WCBuildIssueTypeWarning)
				[[NSColor yellowColor] setFill];
			
			NSRectFill(NSMakeRect(NSMinX(slotRect), NSMinY(slotRect)+floor(NSMinY(lineRect)/yScale), NSWidth(slotRect), 1.0));
		}
	}
}

@synthesize scrollView=_scrollView;
@synthesize buildIssues=_buildIssues;
- (void)setBuildIssues:(NSArray *)buildIssues {
	[_buildIssues release];
	_buildIssues = [buildIssues copy];
	
	[self setNeedsDisplay:YES];
}
@end
