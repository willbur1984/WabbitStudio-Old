//
//  WCProjectNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectNavigatorOutlineView.h"

@implementation WCProjectNavigatorOutlineView
#pragma mark *** Subclass Overrides ***
+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Show in Finder", @"Show in Finder") action:@selector(showInFinder:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Open with External Editor", @"Open with External Editor") action:@selector(openWithExternalEditor:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"New Group", @"New Group") action:@selector(newGroup:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"New Group from Selection", @"New Group from Selection") action:@selector(newGroupFromSelection:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Ungroup Selection", @"Ungroup Selection") action:@selector(ungroupSelection:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Add Files to Project\u2026", @"Add Files to Project with ellipsis") action:@selector(addFilesToProject:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete\u2026", @"Delete with ellipsis") action:@selector(delete:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Rename", @"Rename") action:@selector(rename:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Open in Separate Editor", @"Open in Separate Editor") action:@selector(openInSeparateEditor:) keyEquivalent:@""];
	});
	return retval;
}

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
