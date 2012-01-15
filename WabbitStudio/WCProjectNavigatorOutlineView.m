//
//  WCProjectNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectNavigatorOutlineView.h"

@implementation WCProjectNavigatorOutlineView
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Filter Results", @"No Filter Results");
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
	return NO;
}
@end
