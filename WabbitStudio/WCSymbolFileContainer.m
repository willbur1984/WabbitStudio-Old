//
//  WCSymbolFileContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSymbolFileContainer.h"
#import "WCProject.h"

@implementation WCSymbolFileContainer
- (BOOL)isLeafNode {
	return NO;
}

+ (id)symbolFileContainerWithFile:(WCFile *)file; {
	return [[(WCSymbolFileContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	return self;
}

@dynamic statusString;
- (NSString *)statusString {
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {
		NSUInteger symbolCount = 0;
		
		for (WCSymbolFileContainer *container in [self childNodes])
			symbolCount += [[container childNodes] count];
		
		return [NSString stringWithFormat:NSLocalizedString(@"%lu symbols total", @"total symbols format string"),symbolCount];
	}
	else {
		return [NSString stringWithFormat:NSLocalizedString(@"%lu symbols", @"symbols format string"),[[self childNodes] count]];
	}
}
@end
