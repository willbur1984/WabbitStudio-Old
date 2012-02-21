//
//  WCBreakpointFileContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointFileContainer.h"
#import "WCProject.h"

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
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {
		NSArray *nodes = [self descendantLeafNodes];
		
		if ([nodes count] == 1)
			return NSLocalizedString(@"1 breakpoint", @"1 breakpoint");
		return [NSString stringWithFormat:NSLocalizedString(@"%lu breakpoints", @"breakpoints total format string"),[nodes count]];
	}
	else {
		if ([[self childNodes] count] == 1)
			return NSLocalizedString(@"1 breakpoint", @"1 breakpoint");
		return [NSString stringWithFormat:NSLocalizedString(@"%lu breakpoints", @"breakpoints total format string"),[[self childNodes] count]];
	}
}
@end
