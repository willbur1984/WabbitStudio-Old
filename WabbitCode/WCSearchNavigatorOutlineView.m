//
//  WCSearchNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSearchNavigatorOutlineView.h"

@implementation WCSearchNavigatorOutlineView
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Search Results", @"No Search Results");
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
