//
//  WCSearchResultContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSearchResultContainer.h"

@implementation WCSearchResultContainer
+ (id)searchResultContainerWithSearchResult:(WCSearchResult *)searchResult; {
	return [[[[self class] alloc] initWithSearchResult:searchResult] autorelease];
}
- (id)initWithSearchResult:(WCSearchResult *)searchResult; {
	if (!(self = [super initWithRepresentedObject:searchResult]))
		return nil;
	
	return self;
}
@end
