//
//  NSPointerArray+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSPointerArray+WCExtensions.h"
#import "RSDefines.h"

static inline NSUInteger NSRangeSizeFunction(const void *item) {
	return sizeof(NSRange);
}
static inline NSString *NSRangeDescriptionFunction(const void *item) {
	return NSStringFromRange(*(NSRangePointer)item);
}

@implementation NSPointerArray (WCExtensions)

+ (id)pointerArrayForRanges; {
	NSPointerFunctions *pointerFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsMallocMemory|NSPointerFunctionsStructPersonality|NSPointerFunctionsCopyIn];
	[pointerFunctions setSizeFunction:&NSRangeSizeFunction];
	[pointerFunctions setDescriptionFunction:&NSRangeDescriptionFunction];
	
	return [self pointerArrayWithPointerFunctions:pointerFunctions];
}

- (NSRange)rangeForRange:(NSRange)range {
	if (![self count])
		return NSNotFoundRange;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = ((NSRangePointer)[self pointerAtIndex:mid])->location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return *(NSRangePointer)[self pointerAtIndex:mid];
    }
    return *(NSRangePointer)[self pointerAtIndex:left];
}
- (NSPointerArray *)rangesForRange:(NSRange)range; {
	NSUInteger rangeIndex = [self objectIndexForRange:range];
	
	if (rangeIndex == NSNotFound)
		return nil;
	
	NSPointerArray *retval = [NSPointerArray pointerArrayForRanges];
	
	while (rangeIndex < [self count]) {
		NSRange cmpRange = *(NSRangePointer)[self pointerAtIndex:rangeIndex++];
		
		if (cmpRange.location < range.location)
			continue;
		else if (cmpRange.location > NSMaxRange(range))
			break;
		
		[retval addPointer:&cmpRange];
	}
	return retval;
}

- (NSUInteger)objectIndexForRange:(NSRange)range {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, lineStart;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		lineStart = ((NSRangePointer)[self pointerAtIndex:mid])->location;
        
        if (range.location < lineStart)
			right = mid;
        else if (range.location > lineStart)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (NSRange)rangeGreaterThanOrEqualToRange:(NSRange)range; {
	NSUInteger rangeIndex = [self objectIndexForRange:range];
	if (rangeIndex == NSNotFound)
		return NSNotFoundRange;
	
	while (rangeIndex < [self count]) {
		NSRange cmpRange = *(NSRangePointer)[self pointerAtIndex:rangeIndex++];
		
		if (cmpRange.location >= NSMaxRange(range))
			return cmpRange;
	}
	return NSNotFoundRange;
}

- (NSRange)rangeLessThenRange:(NSRange)range; {
	NSInteger rangeIndex = [self objectIndexForRange:range];
	if (rangeIndex == NSNotFound)
		return NSNotFoundRange;
	
	while (rangeIndex > 0) {
		NSRange cmpRange = *(NSRangePointer)[self pointerAtIndex:rangeIndex--];
		
		if (cmpRange.location < range.location)
			return cmpRange;
	}
	return *(NSRangePointer)[self pointerAtIndex:0];
}
@end
