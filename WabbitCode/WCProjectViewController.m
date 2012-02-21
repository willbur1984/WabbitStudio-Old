//
//  WCProjectViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectViewController.h"
#import "RSDefines.h"

NSString *const WCProjectAutoSaveKey = @"projectAutoSave";
NSString *const WCProjectBuildProductsLocationKey = @"projectBuildProductsLocation";
NSString *const WCProjectBuildProductsLocationCustomKey = @"projectBuildProductsLocationCustom";

@implementation WCProjectViewController

#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	return self;
}

- (NSString *)nibName {
	return @"WCProjectView";
}

#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitstudio.project";
}

- (NSString *)label {
	return NSLocalizedString(@"Project", @"Project");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"project"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:WCProjectAutoSaveAlways],WCProjectAutoSaveKey,[NSNumber numberWithUnsignedInt:WCProjectBuildProductsLocationProjectFolder],WCProjectBuildProductsLocationKey,[[NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES] path],WCProjectBuildProductsLocationCustomKey, nil];
}

#pragma mark *** Public Methods ***
- (IBAction)chooseCustomBuildProductsLocation:(id)sender; {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setPrompt:LOCALIZED_STRING_CHOOSE];
	
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
		[openPanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		[[NSUserDefaults standardUserDefaults] setObject:[[[openPanel URLs] lastObject] path] forKey:WCProjectBuildProductsLocationCustomKey];
	}];
}

@end
