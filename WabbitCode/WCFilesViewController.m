//
//  WCFilesViewController.m
//  WabbitStudio
//
//  Created by William Towe on 4/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFilesViewController.h"
#import "RSDefines.h"

NSString *const WCFilesOpenFilesWithKey = @"filesOpenFilesWith";

@implementation WCFilesViewController

#pragma mark *** Subclass Overrides ***
- (id)init {
	return [super initWithNibName:[self nibName] bundle:nil];
}

- (NSString *)nibName {
	return @"WCFilesView";
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitcode.advanced.files";
}

- (NSString *)label {
	return NSLocalizedString(@"Files", @"Files");
}

- (NSImage *)image {
	return [NSImage imageNamed:NSImageNameMultipleDocuments];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:RSNumberWithInt(WCFilesOpenFilesWithSingleClick),WCFilesOpenFilesWithKey, nil];
}

@end
