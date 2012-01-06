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
	
	for (inputIndex=0; inputIndex<inputLength; inputIndex++) {
		[pattern appendFormat:@"[^%@]*(%@)",[inputString substringWithRange:NSMakeRange(inputIndex, 1)],[inputString substringWithRange:NSMakeRange(inputIndex, 1)]];
	}
	
	[pattern appendString:@".*"];
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
	
#ifdef DEBUG
    NSAssert(regex, @"regex cannot be nil!");
	NSLogObject(pattern);
#endif
	
	for (id <WCJumpInItem> item in [_windowController items]) {
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		NSString *itemString = [[item jumpInName] lowercaseString];
		
		NSTextCheckingResult *result = [regex firstMatchInString:itemString options:0 range:NSMakeRange(0, [itemString length])];
		
		if (!result)
			continue;
		
		NSUInteger rangeIndex, rangeCount = [result numberOfRanges];
		for (rangeIndex=1; rangeIndex<rangeCount; rangeIndex++) {
			[indexes addIndexesInRange:[result rangeAtIndex:rangeIndex]];
		}
		
		NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:0];
		CGFloat itemWeight = [indexes count];
		
		[indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
			[ranges addObject:[NSValue valueWithRange:range]];
		}];
		
		[matches addObject:[WCJumpInMatch jumpInMatchWithItem:item ranges:ranges weight:itemWeight/[ranges count]]];
	}
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[matches sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weightNumber" ascending:NO selector:@selector(compare:)],[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
		return [[[obj1 item] jumpInName] localizedStandardCompare:[[obj2 item] jumpInName]];
	}], nil]];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([matches count])
			[_windowController setStatusString:nil];
		else
			[_windowController setStatusString:[NSString stringWithFormat:NSLocalizedString(@"found %lu of %lu matche(s)", @"jump in window status format string"),[matches count],[[_windowController items] count]]];
		[[_windowController mutableMatches] setArray:matches];
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
