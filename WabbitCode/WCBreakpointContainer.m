//
//  WCBreakpointContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointContainer.h"
#import "WCSourceSymbol.h"
#import "WCFileBreakpoint.h"
#import "WCBreakpointFileContainer.h"
#import "WCProjectDocument.h"
#import "WCSourceScanner.h"
#import "WCSourceFileDocument.h"
#import "NSArray+WCExtensions.h"
#import "WCSourceTextStorage.h"
#import "NSString+RSExtensions.h"

@implementation WCBreakpointContainer
#pragma mark *** Subclass Overrides ***
- (BOOL)isLeafNode {
	return YES;
}
#pragma mark *** Public Methods ***
+ (id)breakpointContainerWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint; {
	return [[[[self class] alloc] initWithFileBreakpoint:fileBreakpoint] autorelease];
}
- (id)initWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint; {
	if (!(self = [super initWithRepresentedObject:fileBreakpoint]))
		return nil;
	
	return self;
}

@end
