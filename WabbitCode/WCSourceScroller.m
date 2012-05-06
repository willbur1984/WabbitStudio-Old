//
//  WCSourceScroller.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

- (void)setNeedsDisplayInRect:(NSRect)invalidRect {
	if ([[self buildIssues] count] || [[self bookmarks] count])
		[super setNeedsDisplayInRect:[self bounds]];
	else
		[super setNeedsDisplayInRect:invalidRect];
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
	[super drawKnobSlotInRect:slotRect highlight:flag];
	
	if ([[self buildIssues] count] || [[self bookmarks] count]) {
		NSTextView *textView = (NSTextView *)[(NSScrollView *)[self superview] documentView];
		NSLayoutManager *layoutManager = [textView layoutManager];
		CGFloat yposScale = NSHeight([textView frame])/NSHeight([self bounds]);
		
		for (WCBuildIssue *buildIssue in [self buildIssues]) {
			NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:[buildIssue range].location] effectiveRange:NULL];
			
			lineRect = NSInsetRect(NSMakeRect(NSMinX(slotRect), NSMinY(slotRect)+floor(NSMinY(lineRect)/yposScale), NSWidth(slotRect), 1.0), 1.0, 0.0);
			
			if (!NSIntersectsRect(lineRect, slotRect) || ![self needsToDrawRect:lineRect])
				continue;
			
			if ([buildIssue type] == WCBuildIssueTypeError)
				[[NSColor redColor] setFill];
			else if ([buildIssue type] == WCBuildIssueTypeWarning)
				[[NSColor colorWithCalibratedRed:246.0/255.0 green:176.0/255.0 blue:30.0/255.0 alpha:1.0] setFill];

			NSRectFill(lineRect);
		}
		
		for (RSBookmark *bookmark in [self bookmarks]) {
			NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:[bookmark range].location] effectiveRange:NULL];
			
			[[NSColor blueColor] setFill];
			NSRectFill(NSInsetRect(NSMakeRect(NSMinX(slotRect), NSMinY(slotRect)+floor(NSMinY(lineRect)/yposScale), NSWidth(slotRect), 1.0), 1.0, 0.0));
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
