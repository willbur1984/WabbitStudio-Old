//
//  WEApplicationDelegate.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEApplicationDelegate.h"
#import "WEPreferencesWindowController.h"

@implementation WEApplicationDelegate
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}

- (IBAction)preferences:(id)sender; {
	[[WEPreferencesWindowController sharedWindowController] showWindow:nil];
}
@end
