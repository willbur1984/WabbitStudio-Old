//
//  NSTextView+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSTextView+WCExtensions.h"

@implementation NSTextView (WCExtensions)
- (NSRange)visibleRange; {
	if (![[self string] length])
		return NSMakeRange(0, 0);
	
	NSRect visibleRect = [self visibleRect];
	NSRange visibleRange = [[self layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[self textContainer]];
	NSRange charRange = [[self layoutManager] characterRangeForGlyphRange:visibleRange actualGlyphRange:NULL];
	NSUInteger firstChar = [[self string] lineRangeForRange:NSMakeRange(charRange.location, 0)].location;
	NSUInteger lastChar = NSMaxRange([[self string] lineRangeForRange:NSMakeRange(NSMaxRange(charRange), 0)]);
	
	return NSMakeRange(firstChar, lastChar-firstChar);
}
@end
