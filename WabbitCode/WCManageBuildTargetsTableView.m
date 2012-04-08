//
//  WCManageBuildTargetsTableView.m
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCManageBuildTargetsTableView.h"

@implementation WCManageBuildTargetsTableView
#pragma mark *** Subclass Overrides ***
+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"New Build Target", @"New Build Target") action:@selector(newBuildTarget:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"New Build Target from Template", @"New Build Target from Template") action:@selector(newBuildTargetFromTemplate:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete Build Target", @"Delete Build Target") action:@selector(deleteBuildTarget:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Duplicate Build Target", @"Duplicate Build Target") action:@selector(duplicateBuildTarget:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Rename Build Target", @"Rename Build Target") action:@selector(renameBuildTarget:) keyEquivalent:@""];
	});
	return retval;
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Build Targets", @"No Build Targets");
}
@end
