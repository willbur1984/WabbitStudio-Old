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
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {
		NSUInteger total = 0;
		
		for (RSTreeNode *node in [self childNodes])
			total += [[node childNodes] count];
		
		if (total == 1)
			return NSLocalizedString(@"1 result total", @"1 result total");
		return [NSString stringWithFormat:NSLocalizedString(@"%lu results total", @"search container search status project format string"),total];
	}
	if ([[self childNodes] count] == 1)
		return NSLocalizedString(@"1 result", @"1 result");
	return [NSString stringWithFormat:NSLocalizedString(@"%lu results", @"search container search status format string"),[[self childNodes] count]];
}
@end
