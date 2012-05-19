//
//  WCApplicationDelegate.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
#import "WCAddToProjectAccessoryViewController.h"
#import "WCProjectViewController.h"
#import "WCNewFileWindowController.h"

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
	[userDefaults addEntriesFromDictionary:[WCAddToProjectAccessoryViewController userDefaults]];
	[userDefaults addEntriesFromDictionary:[WCProjectViewController userDefaults]];
	
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
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}
#pragma mark *** Public Methods ***

#pragma mark IBActions
- (IBAction)preferences:(id)sender; {
	[[WCPreferencesWindowController sharedWindowController] showWindow:nil];
}

- (IBAction)newFile:(id)sender; {
	WCProjectDocument *currentProjectDocument = [[WCDocumentController sharedDocumentController] currentProjectDocument];
	
	if (currentProjectDocument) {
		WCNewFileWindowController *newFileWindowController = [WCNewFileWindowController newFileWindowControllerWithProjectDocument:currentProjectDocument];
		
		[newFileWindowController showNewFileWindow];
	}
	else {
		[[WCNewFileWindowController sharedWindowController] showNewFileWindow];
	}
}
- (IBAction)newProject:(id)sender; {
	[[NSApplication sharedApplication] runModalForWindow:[[WCNewProjectWindowController sharedWindowController] window]];
}
@end
