//
//  WCBreakpointNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointNavigatorOutlineView.h"

@implementation WCBreakpointNavigatorOutlineView
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Breakpoints", @"No Breakpoints");
}
- (BOOL)shouldDrawEmptyContentString {
	if ([self numberOfRows] == 1) {
		if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
			return (![[[self itemAtRow:0] childNodes] count]);
		}
		else {
			return (![[self dataSource] outlineView:self numberOfChildrenOfItem:[self itemAtRow:0]]);
		}
	}
	else if (![self numberOfRows])
		return YES;
	return NO;
}
@end
