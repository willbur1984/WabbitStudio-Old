//
//  WCProjectViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/28/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
	return @"org.revsoft.wabbitcode.project";
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
