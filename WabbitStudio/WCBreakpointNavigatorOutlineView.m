//
//  WCBreakpointNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointNavigatorOutlineView.h"

@implementation WCBreakpointNavigatorOutlineView
+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Edit Breakpoint", @"Edit Breakpoint") action:@selector(editBreakpoint:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Disable Breakpoint", @"Disable Breakpoint") action:@selector(toggleBreakpoint:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete Breakpoint", @"Delete Breakpoint") action:@selector(deleteBreakpoint:) keyEquivalent:@""];
	});
	return retval;
}

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
