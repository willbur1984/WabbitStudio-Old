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
#import "WCKeyBindingCommandSetManager.h"
#import "WCKeyBindingsViewController.h"
#import "WCGeneralViewController.h"
#import "WCDocumentController.h"

@implementation WCApplicationDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	NSMutableDictionary *userDefaults = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[userDefaults addEntriesFromDictionary:[WCFontsAndColorsViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCEditorViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCAdvancedViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCKeyBindingsViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCGeneralViewController userDefaults]];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[[WCKeyBindingCommandSetManager sharedManager] loadKeyBindingsFromCurrentCommandSet];
	
	WCGeneralOnStartup startupAction = [[[NSUserDefaults standardUserDefaults] objectForKey:WCGeneralOnStartupKey] unsignedIntValue];
	switch (startupAction) {
		case WCGeneralOnStartupShowNewProjectWindow:
			break;
		case WCGeneralOnStartupOpenMostRecentProject:
			break;
		case WCGeneralOnStartupOpenUntitledDocument:
			[[WCDocumentController sharedDocumentController] newDocument:nil];
			break;
		case WCGeneralOnStartupDoNothing:
		default:
			break;
	}
}

- (IBAction)preferences:(id)sender; {
	[[WCPreferencesWindowController sharedWindowController] showWindow:nil];
}
@end
