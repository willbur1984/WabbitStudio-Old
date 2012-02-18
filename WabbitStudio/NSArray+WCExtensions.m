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
#import "WCBuildIssue.h"
#import "WCFileBreakpoint.h"

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
		NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[self count]];
		
		for (WCSourceToken *token in [self subarrayWithRange:NSMakeRange(startIndex, [self count] - startIndex)]) {
			if ([token range].location > NSMaxRange(range))
				break;
			
			[retval addObject:token];
		}
		
		return retval;
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
		NSUInteger startIndex = [self sourceTokenIndexForRange:range];
		NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[self count]];
		
		for (WCSourceSymbol *symbol in [self subarrayWithRange:NSMakeRange(startIndex, [self count] - startIndex)]) {
			if ([symbol range].location > NSMaxRange(range))
				break;
			
			[retval addObject:symbol];
		}
		
		return retval;
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
		NSUInteger startIndex = [self bookmarkIndexForRange:range];
		NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[self count]];
		
		[retval addObject:[self objectAtIndex:startIndex]];
		
		for (RSBookmark *bookmark in [self subarrayWithRange:NSMakeRange(startIndex, [self count] - startIndex)]) {
			if ([bookmark range].location > NSMaxRange(range))
				break;
			
			[retval addObject:bookmark];
		}
		
		return retval;
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
		if (NSIntersectionRange(range, [[self lastObject] range]).length)
			return self;
		return nil;
	}
	else {
		NSUInteger startIndex = [self foldIndexForRange:range];
		NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[self count]];
		
		for (WCFold *fold in [self subarrayWithRange:NSMakeRange(startIndex, [self count] - startIndex)]) {
			if ([fold range].location > NSMaxRange(range))
				break;
			
			[retval addObject:fold];
		}
		
		return retval;
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

- (NSUInteger)buildIssueIndexForRange:(NSRange)range; {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = [(WCBuildIssue *)[self objectAtIndex:mid] range].location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (WCBuildIssue *)buildIssueForRange:(NSRange)range; {
	if (![self count])
		return nil;
	
	return [self objectAtIndex:[self buildIssueIndexForRange:range]];
}
- (NSArray *)buildIssuesForRange:(NSRange)range; {
	if (![self count])
		return nil;
	else if ([self count] == 1) {
		if (NSLocationInOrEqualToRange([[self lastObject] range].location, range))
			return self;
		return nil;
	}
	else {
		NSUInteger startIndex = [self buildIssueIndexForRange:range];
		NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[self count]];
		
		for (WCBuildIssue *buildIssue in [self subarrayWithRange:NSMakeRange(startIndex, [self count] - startIndex)]) {
			if ([buildIssue range].location > NSMaxRange(range))
				break;
			
			[retval addObject:buildIssue];
		}
		
		return [[retval copy] autorelease];
	}
}

- (NSUInteger)fileBreakpointIndexForRange:(NSRange)range; {
	if (![self count])
		return NSNotFound;
	
	NSUInteger left = 0, right = [self count], mid, searchLocation;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
		searchLocation = [(WCFileBreakpoint *)[self objectAtIndex:mid] range].location;
        
        if (range.location < searchLocation)
			right = mid;
        else if (range.location > searchLocation)
			left = mid;
        else
			return mid;
    }
    return left;
}
- (WCFileBreakpoint *)fileBreakpointForRange:(NSRange)range; {
	if (![self count])
		return nil;
	
	WCFileBreakpoint *fileBreakpoint = [self objectAtIndex:[self fileBreakpointIndexForRange:range]];
	if ([fileBreakpoint range].location == range.location)
		return fileBreakpoint;
	return nil;
}
- (NSArray *)fileBreakpointsForRange:(NSRange)range; {
	if (![self count])
		return nil;
	else if ([self count] == 1) {
		if (NSLocationInOrEqualToRange([[self lastObject] range].location, range))
			return self;
		return nil;
	}
	else {
		NSUInteger startIndex = [self fileBreakpointIndexForRange:range];
		NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[self count]];
		
		for (WCFileBreakpoint *fileBreakpoint in [self subarrayWithRange:NSMakeRange(startIndex, [self count] - startIndex)]) {
			if ([fileBreakpoint range].location > NSMaxRange(range))
				break;
			
			[retval addObject:fileBreakpoint];
		}
		
		return [[retval copy] autorelease];
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

@implementation NSMutableArray (WCExtensions)
- (void)removeFirstObject; {
	if ([self count])
		[self removeObjectAtIndex:0];
}
@end