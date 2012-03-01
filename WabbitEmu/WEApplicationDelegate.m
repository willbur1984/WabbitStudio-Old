//
//  WEApplicationDelegate.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEApplicationDelegate.h"
#import "WEPreferencesWindowController.h"
#import "RSCalculator.h"

@implementation WEApplicationDelegate
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[userDefaults addEntriesFromDictionary:[RSCalculator userDefaults]];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

- (IBAction)preferences:(id)sender; {
	[[WEPreferencesWindowController sharedWindowController] showWindow:nil];
}
@end
