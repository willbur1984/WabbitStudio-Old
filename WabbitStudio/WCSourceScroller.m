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
#import "RSBookmark.h"

@implementation WCSourceScroller
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_bookmarks release];
	[_buildIssues release];
	[super dealloc];
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
	[super drawKnobSlotInRect:slotRect highlight:flag];
	
	if ([[self buildIssues] count] || [[self bookmarks] count]) {
		NSTextView *textView = (NSTextView *)[(NSScrollView *)[self superview] documentView];
		NSLayoutManager *layoutManager = [textView layoutManager];
		CGFloat yposScale = NSHeight([textView frame])/NSHeight(slotRect);
		
		for (WCBuildIssue *buildIssue in [self buildIssues]) {
			NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:[buildIssue range].location] effectiveRange:NULL];
			
			if ([buildIssue type] == WCBuildIssueTypeError)
				[[NSColor redColor] setFill];
			else if ([buildIssue type] == WCBuildIssueTypeWarning)
				[[NSColor colorWithCalibratedRed:246.0/255.0 green:176.0/255.0 blue:30.0/255.0 alpha:1.0] setFill];

			NSRectFill(NSInsetRect(NSMakeRect(NSMinX(slotRect), /*NSMinY(slotRect)+*/floor(NSMinY(lineRect)/yposScale), NSWidth(slotRect), 1.0), 1.0, 0.0));
		}
		
		for (RSBookmark *bookmark in [self bookmarks]) {
			NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:[bookmark range].location] effectiveRange:NULL];
			
			[[NSColor blueColor] setFill];
			NSRectFill(NSInsetRect(NSMakeRect(NSMinX(slotRect), /*NSMinY(slotRect)+*/floor(NSMinY(lineRect)/yposScale), NSWidth(slotRect), 1.0), 1.0, 0.0));
		}
	}
}

@synthesize buildIssues=_buildIssues;
- (void)setBuildIssues:(NSArray *)buildIssues {
	if (_buildIssues != buildIssues) {
		[_buildIssues release];
		_buildIssues = [buildIssues retain];
	}
	
	[self setNeedsDisplay:YES];
}
@synthesize bookmarks=_bookmarks;
- (void)setBookmarks:(NSArray *)bookmarks {
	if (_bookmarks != bookmarks) {
		[_bookmarks release];
		_bookmarks = [bookmarks retain];
	}
	
	[self setNeedsDisplay:YES];
}
@end
