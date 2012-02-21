//
//  WCTabViewWindow.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTabViewWindow.h"
#import "WCTabViewController.h"

#import <PSMTabBarControl/PSMTabBarControl.h>

@implementation WCTabViewWindow
- (void)performClose:(id)sender {
	NSTabViewItem *selectedTabViewItem = [[[[self tabViewController] tabBarControl] tabView] selectedTabViewItem];
	
	if (selectedTabViewItem) {
		NSArray *tabViewItems = [[[self tabViewController] tabBarControl] representedTabViewItems];
		
		if ([tabViewItems count] > 1)
			[[[[self tabViewController] tabBarControl] tabView] removeTabViewItem:selectedTabViewItem];
		else if ([tabViewItems count] == 1 && [[[self tabViewController] tabBarControl] canCloseOnlyTab])
			[[[[self tabViewController] tabBarControl] tabView] removeTabViewItem:selectedTabViewItem];
		else
			[super performClose:sender];
	}
	else
		[super performClose:sender];
}

@synthesize tabViewController=_tabViewController;

@end
