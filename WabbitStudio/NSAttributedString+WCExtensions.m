//
//  NSAttributedString+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSAttributedString+WCExtensions.h"
#import "WCArgumentPlaceholderCell.h"
#import "RSDefines.h"
#import "NSPointerArray+WCExtensions.h"
#import "NSString+RSExtensions.h"

@implementation NSAttributedString (WCExtensions)
- (NSRange)nextArgumentPlaceholderRangeForRange:(NSRange)compareRange inRange:(NSRange)range wrapAround:(BOOL)wrapAround; {
	NSPointerArray *ranges = [NSPointerArray pointerArrayForRanges];
	__block NSRange retval = NSNotFoundRange;
	
	[self enumerateAttribute:NSAttachmentAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange attrRange, BOOL *stop) {
		if ([[value attachmentCell] isKindOfClass:[WCArgumentPlaceholderCell class]]) {
			[ranges addPointer:&attrRange];
			if (attrRange.location >= NSMaxRange(compareRange)) {
				retval = attrRange;
				*stop = YES;
			}
		}
	}];
	
	if (retval.location == NSNotFound && wrapAround && [ranges count])
		return *(NSRangePointer)[ranges pointerAtIndex:0];
	
	return retval;
}
- (NSRange)previousArgumentPlaceholderRangeForRange:(NSRange)compareRange inRange:(NSRange)range wrapAround:(BOOL)wrapAround; {
	NSPointerArray *ranges = [NSPointerArray pointerArrayForRanges];
	__block NSRange retval = NSNotFoundRange;
	
	// using NSAttributedStringEnumerationReverse caused a crash every time
	[self enumerateAttribute:NSAttachmentAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange attrRange, BOOL *stop) {
		if ([[value attachmentCell] isKindOfClass:[WCArgumentPlaceholderCell class]]) {
			[ranges addPointer:&attrRange];
		}
	}];
	
	NSInteger rangeIndex, rangeCount = [ranges count];
	
	for (rangeIndex = rangeCount-1; rangeIndex >= 0; rangeIndex--) {
		NSRange attrRange = *(NSRangePointer)[ranges pointerAtIndex:rangeIndex];
		
		if (attrRange.location < compareRange.location) {
			retval = attrRange;
			break;
		}
	}
	
	if (retval.location == NSNotFound && wrapAround && [ranges count])
		return *(NSRangePointer)[ranges pointerAtIndex:rangeCount-1];
	
	return retval;
}

- (NSUInteger)lineNumberForRange:(NSRange)range; {
	return [[self string] lineNumberForRange:range];
}
@end
