//
//  WCPreferencesWindowController.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCPreferencesWindowController.h"
#import "WCFontsAndColorsViewController.h"
#import "WCFontAndColorThemeManager.h"
#import "WCEditorViewController.h"
#import "WCAdvancedViewController.h"
#import "WCKeyBindingsViewController.h"

@implementation WCPreferencesWindowController
- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
}

+ (NSString *)windowNibName; {
	return @"WCPreferencesWindow";
}

- (void)setupViewControllers {
	[self addViewController:[[[WCEditorViewController alloc] init] autorelease]];
	[self addViewController:[[[WCFontsAndColorsViewController alloc] init] autorelease]];
	[self addViewController:[[[WCKeyBindingsViewController alloc] init] autorelease]];
	[self addViewController:[[[WCAdvancedViewController alloc] init] autorelease]];
}

- (void)_applicationWillTerminate:(NSNotification *)note {
	[[WCFontAndColorThemeManager sharedManager] saveCurrentThemes:NULL];
}
- (void)_windowWillClose:(NSNotification *)note {
	[[WCFontAndColorThemeManager sharedManager] saveCurrentThemes:NULL];
}
@end
