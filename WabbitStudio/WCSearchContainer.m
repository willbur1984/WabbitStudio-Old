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

+ (id)searchContainerWithFile:(WCFile *)file; {
	return [[(WCSearchContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	return self;
}

@dynamic searchStatus;
- (NSString *)searchStatus {
	if ([[self representedObject] isKindOfClass:[WCProject class]])
		return NSLocalizedString(@"Search for some stuffs!", @"Search for some stuffs!");
	return [NSString stringWithFormat:NSLocalizedString(@"%lu result(s)", @"search container search status format string"),[[self childNodes] count]];
}
@end
