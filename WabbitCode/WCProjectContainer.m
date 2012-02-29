//
//  WCProjectContainer.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectContainer.h"
#import "WCFile.h"

@implementation WCProjectContainer
#pragma mark *** Subclass Overrides ***

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	NSMutableArray *childNodePlists = [NSMutableArray arrayWithCapacity:[[self childNodes] count]];
	for (RSTreeNode *node in [self childNodes])
		[childNodePlists addObject:[node plistRepresentation]];
	
	[retval setObject:childNodePlists forKey:RSTreeNodeChildNodesKey];
	
	return [[retval copy] autorelease];
}

- (NSURL *)locationURLForFile:(WCFile *)file {
	return [NSURL URLWithString:[file fileName]];
}

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
