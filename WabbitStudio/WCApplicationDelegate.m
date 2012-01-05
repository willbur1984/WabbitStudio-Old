//
//  WCApplicationDelegate.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCApplicationDelegate.h"
#import "WCFontsAndColorsViewController.h"
#import "WCPreferencesWindowController.h"
#import "WCEditorViewController.h"
#import "WCAdvancedViewController.h"

@implementation WCApplicationDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[userDefaults addEntriesFromDictionary:[WCFontsAndColorsViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCEditorViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCAdvancedViewController userDefaults]];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

- (IBAction)preferences:(id)sender; {
	[[WCPreferencesWindowController sharedWindowController] showWindow:nil];
}
@end
