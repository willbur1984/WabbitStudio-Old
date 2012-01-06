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

@implementation WCJumpInSearchOperation
- (void)dealloc {
	_windowController = nil;
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *searchString = [[[_windowController searchString] copy] autorelease];
	
	NSMutableArray *matches = [NSMutableArray arrayWithCapacity:0];
	NSSet *substrings = [searchString substrings];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	for (id <WCJumpInItem> item in [_windowController items]) {
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		
		for (NSString *string in substrings) {
			NSRange matchRange = [[item jumpInName] rangeOfString:string options:NSLiteralSearch|NSCaseInsensitiveSearch];
			if (matchRange.location == NSNotFound)
				continue;
			
			[indexes addIndexesInRange:matchRange];
		}
		
		if ([self isCancelled])
			goto CLEANUP;
		
		if (![indexes count] || [indexes count] > [searchString length])
			continue;
		
		NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:0];
		
		[indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
			[ranges addObject:[NSValue valueWithRange:range]];
		}];
		
		[matches addObject:[WCJumpInMatch jumpInMatchWithItem:item ranges:ranges weight:[indexes count]]];
	}
	
	[matches sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weightNumber" ascending:NO selector:@selector(compare:)],[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
		return [[[obj1 item] jumpInName] localizedStandardCompare:[[obj2 item] jumpInName]];
	}], nil]];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[_windowController mutableMatches] removeAllObjects];
		[[_windowController mutableMatches] addObjectsFromArray:matches];
	});
	
CLEANUP:
	[pool release];
}

- (id)initWithJumpInWindowController:(WCJumpInWindowController *)windowController; {
	if (!(self = [super init]))
		return nil;
	
	_windowController = windowController;
	
	return self;
}
@end
