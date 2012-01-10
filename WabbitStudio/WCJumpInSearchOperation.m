//
//  WCJumpInSearchOperation.m
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpInSearchOperation.h"
#import "WCJumpInWindowController.h"
#import "NSString+WCExtensions.h"
#import "WCJumpInMatch.h"
#import "RSDefines.h"

@implementation WCJumpInSearchOperation
- (void)dealloc {
	_windowController = nil;
	[_searchString release];
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *inputString = _searchString;
	
	NSMutableArray *matches = [NSMutableArray arrayWithCapacity:0];
	NSMutableString *pattern = [NSMutableString stringWithCapacity:0];
	NSUInteger inputIndex, inputLength = [inputString length];
	
	// transform the inputString into a regex pattern string
	// "abc" would transform into "[^a]*(a)[^b]*(b)[^c]*(c).*"
	// the capture groups let us track the ranges in the itemString that match the inputString
	for (inputIndex=0; inputIndex<inputLength; inputIndex++) {
		NSString *substring = [NSRegularExpression escapedPatternForString:[inputString substringWithRange:NSMakeRange(inputIndex, 1)]];
		[pattern appendFormat:@"[^%@]*(%@)",substring,substring];
	}
	[pattern appendString:@".*"];
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
	
#ifdef DEBUG
    NSAssert(regex, @"regex cannot be nil!");
#endif
	
	if ([self isCancelled])
		goto CLEANUP;
	
	for (id <WCJumpInItem> item in [_windowController items]) {
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		NSString *itemString = [[item jumpInName] lowercaseString];
		
		// there should be one and only one result if there was a match
		NSTextCheckingResult *result = [regex firstMatchInString:itemString options:0 range:NSMakeRange(0, [itemString length])];
		
		if (!result)
			continue;
		
		// loop through the capture ranges starting with 1st
		// we skip the range at index 0 because that corresponds to the entire range of the match
		NSUInteger rangeIndex, rangeCount = [result numberOfRanges];
		for (rangeIndex=1; rangeIndex<rangeCount; rangeIndex++) {
			[indexes addIndexesInRange:[result rangeAtIndex:rangeIndex]];
		}
		
		// loop through the ranges in the index set
		NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:0];
		[indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
			[ranges addObject:[NSValue valueWithRange:range]];
		}];
		
		// create our new match
		// the weight (at least for now) is the total number of matched characters in the itemString divided by the total number of ranges
		// this ensures we favor contiguous ranges
		[matches addObject:[WCJumpInMatch jumpInMatchWithItem:item ranges:ranges weight:floor([indexes count]/[ranges count])]];
	}
	
	if ([self isCancelled])
		goto CLEANUP;
	
	// sort all the matches first by their weight, then alphabetically
	[matches sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weightNumber" ascending:NO selector:@selector(compare:)],[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
		return [[[obj1 item] jumpInName] localizedStandardCompare:[[obj2 item] jumpInName]];
	}], nil]];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		// set the status string appropriately
		if ([matches count])
			[_windowController setStatusString:[NSString stringWithFormat:NSLocalizedString(@"matched %lu of %lu item(s)", @"jump in window status format string"),[matches count],[[_windowController items] count]]];
		else
			[_windowController setStatusString:nil];
		
		// update the search field's recent searches
		NSMutableArray *recents = [[[[_windowController searchField] recentSearches] mutableCopy] autorelease];
		
		if (![recents containsObject:inputString]) {
			[recents addObject:inputString];
			[[_windowController searchField] setRecentSearches:recents];
		}
		
		// update the matches array
		[[_windowController mutableMatches] setArray:matches];
		
		// stop the progress indicator
		[_windowController setSearching:NO];
	});
	
CLEANUP:
	[pool release];
}

- (id)initWithJumpInWindowController:(WCJumpInWindowController *)windowController; {
	if (!(self = [super init]))
		return nil;
	
	_windowController = windowController;
	_searchString = [[windowController searchString] copy];
	
	return self;
}
@end
