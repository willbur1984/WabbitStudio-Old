//
//  WCBreakpointFileContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointFileContainer.h"

@implementation WCBreakpointFileContainer
- (BOOL)isLeafNode {
	return NO;
}

+ (id)breakpointFileContainerWithFile:(WCFile *)file; {
	return [[(WCBreakpointFileContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	return self;
}

@dynamic statusString;
- (NSString *)statusString {
	return @"some boring status string";
}
@end
