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
#import "RSBookmark.h"
#import "WCFold.h"
#import "RSDefines.h"

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
		if (endIndex < [self count] && NSMaxRange([[self objectAtIndex:endIndex] range]) <= NSMaxRange(range))
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

- (NSUInteger)bookmarkIndexForRange:(NSRange)range; {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = [(RSBookmark *)[self objectAtIndex:mid] range].location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (RSBookmark *)bookmarkForRange:(NSRange)range; {
	if (![self count])
		return nil;
	
	return [self objectAtIndex:[self bookmarkIndexForRange:range]];
}
- (NSArray *)bookmarksForRange:(NSRange)range; {
	if (![self count])
		return nil;
	else if ([self count] == 1) {
		if (NSLocationInRange([[self lastObject] range].location, range))
			return self;
		return nil;
	}
	else {
		NSUInteger startIndex = [self sourceSymbolIndexForRange:range];
		NSUInteger endIndex = [self sourceSymbolIndexForRange:NSMakeRange(NSMaxRange(range), 0)];
		if (endIndex < [self count])
			endIndex++;
		
		return [self subarrayWithRange:NSMakeRange(startIndex, endIndex-startIndex)];
	}
}

- (NSUInteger)foldIndexForRange:(NSRange)range; {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = [(WCFold *)[self objectAtIndex:mid] range].location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (WCFold *)foldForRange:(NSRange)range; {
	if (![self count])
		return nil;
	
	return [self objectAtIndex:[self foldIndexForRange:range]];
}
- (NSArray *)foldsForRange:(NSRange)range; {
	if (![self count])
		return nil;
	else if ([self count] == 1) {
		if (NSLocationInRange(range.location, [[self lastObject] range]))
			return self;
		return nil;
	}
	else {
		NSUInteger startIndex = [self foldIndexForRange:range];
		NSUInteger endIndex = [self foldIndexForRange:NSMakeRange(NSMaxRange(range), 0)];
		if (startIndex == endIndex)
			return [NSArray arrayWithObject:[self firstObject]];
		else if (endIndex < [self count])
			endIndex++;
		
		return [self subarrayWithRange:NSMakeRange(startIndex, endIndex-startIndex)];
	}
}
- (WCFold *)deepestFoldForRange:(NSRange)range; {
	WCFold *topLevelFold = [self foldForRange:range];
	
	if (!NSLocationInRange(range.location, [topLevelFold range]))
		return nil;
	
	for (WCFold *fold in [topLevelFold descendantNodes]) {
		if (NSLocationInRange(range.location, [fold range]) &&
			[fold range].length < [topLevelFold range].length)
			topLevelFold = fold;
	}
	
	return topLevelFold;
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

@implementation NSMutableArray (WCExtensions)
- (void)removeFirstObject; {
	if ([self count])
		[self removeObjectAtIndex:0];
}
@end