//
//  NSPointerArray+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSPointerArray+WCExtensions.h"
#import "RSDefines.h"

static NSUInteger NSRangeSizeFunction(const void *item) {
	return sizeof(NSRange);
}
static NSString *NSRangeDescriptionFunction(const void *item) {
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
