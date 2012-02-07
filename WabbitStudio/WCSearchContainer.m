//
//  WCSearchContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSearchContainer.h"
#import "WCProject.h"

@implementation WCSearchContainer
- (BOOL)isLeafNode {
	return NO;
}

+ (id)searchContainerWithProject:(WCProject *)project; {
	return [[[[self class] alloc] initWithProject:project] autorelease];
}
- (id)initWithProject:(WCProject *)project; {
	if (!(self = [super initWithRepresentedObject:project]))
		return nil;
	
	return self;
}

@dynamic searchStatus;
- (NSString *)searchStatus {
	return NSLocalizedString(@"Search for some stuffs!", @"Search for some stuffs!");
}
@end
