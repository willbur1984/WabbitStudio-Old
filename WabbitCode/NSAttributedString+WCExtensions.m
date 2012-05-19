//
//  NSAttributedString+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
