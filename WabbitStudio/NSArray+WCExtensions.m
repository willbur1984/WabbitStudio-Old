//
//  NSArray+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSArray+WCExtensions.h"
#import "WCSourceSymbol.h"
#import "WCSourceToken.h"

@implementation NSArray (WCExtensions)
- (NSUInteger)sourceTokenIndexForRange:(NSRange)range; {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = [(WCSourceToken *)[self objectAtIndex:mid] range].location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (WCSourceToken *)sourceTokenForRange:(NSRange)range; {
	if (![self count])
		return nil;
	
	return [self objectAtIndex:[self sourceTokenIndexForRange:range]];
}
- (NSArray *)sourceTokensForRange:(NSRange)range; {
	if (![self count])
		return nil;
	else if ([self count] == 1)
		return self;
	else {
		NSUInteger startIndex = [self sourceTokenIndexForRange:range];
		NSUInteger endIndex = [self sourceTokenIndexForRange:NSMakeRange(NSMaxRange(range), 0)];
		if (endIndex < [self count])
			endIndex++;
		
		return [self subarrayWithRange:NSMakeRange(startIndex, endIndex-startIndex)];
	}
}

- (NSUInteger)sourceSymbolIndexForRange:(NSRange)range; {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = [(WCSourceToken *)[self objectAtIndex:mid] range].location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (WCSourceSymbol *)sourceSymbolForRange:(NSRange)range; {
	if (![self count])
		return nil;
	
	return [self objectAtIndex:[self sourceSymbolIndexForRange:range]];
}
- (NSArray *)sourceSymbolsForRange:(NSRange)range; {
	if (![self count])
		return nil;
	else if ([self count] == 1)
		return self;
	else {
		NSUInteger startIndex = [self sourceSymbolIndexForRange:range];
		NSUInteger endIndex = [self sourceSymbolIndexForRange:NSMakeRange(NSMaxRange(range), 0)];
		if (endIndex < [self count])
			endIndex++;
		
		return [self subarrayWithRange:NSMakeRange(startIndex, endIndex-startIndex)];
	}
}

- (NSUInteger)lineNumberForRange:(NSRange)range; {
	NSUInteger left = 0, right = [self count], mid, lineStart;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
        lineStart = [[self objectAtIndex:mid] unsignedIntegerValue];
        
        if (range.location < lineStart)
			right = mid;
        else if (range.location > lineStart)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (id)firstObject {
	if ([self count])
		return [self objectAtIndex:0];
	return nil;
}
@end
