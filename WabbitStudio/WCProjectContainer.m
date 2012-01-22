//
//  WCProjectContainer.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectContainer.h"

@implementation WCProjectContainer
#pragma mark *** Public Methods ***
+ (id)projectContainerWithProject:(WCProject *)project; {
	return [[[[self class] alloc] initWithProject:project] autorelease];
}
- (id)initWithProject:(WCProject *)project; {
	if (!(self = [super initWithRepresentedObject:project]))
		return nil;
	
	
	return self;
}
#pragma mark Properties
@dynamic project;
- (WCProject *)project {
	return (WCProject *)[self representedObject];
}
@end
