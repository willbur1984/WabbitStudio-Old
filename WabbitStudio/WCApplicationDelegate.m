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
#import "WCNewProjectWindowController.h"

@implementation WCApplicationDelegate
#pragma mark *** Subclass Overrides ***

#pragma mark NSApplicationDelegate
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
			[self newProject:nil];
			break;
		case WCGeneralOnStartupOpenMostRecentProject:
			if ([[[WCDocumentController sharedDocumentController] recentProjectURLs] count])
				[[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[[[WCDocumentController sharedDocumentController] recentProjectURLs] objectAtIndex:0] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
					
				}];
			break;
		case WCGeneralOnStartupOpenUntitledDocument:
			[[WCDocumentController sharedDocumentController] newDocument:nil];
			break;
		case WCGeneralOnStartupDoNothing:
		default:
			break;
	}
	
	[[[NSImage imageNamed:NSImageNameGoRightTemplate] TIFFRepresentation] writeToURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"image.tiff"]] options:NSAtomicWrite error:NULL];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}
#pragma mark *** Public Methods ***

#pragma mark IBActions
- (IBAction)preferences:(id)sender; {
	[[WCPreferencesWindowController sharedWindowController] showWindow:nil];
}
- (IBAction)newProject:(id)sender; {
	[[NSApplication sharedApplication] runModalForWindow:[[WCNewProjectWindowController sharedWindowController] window]];
}
@end
