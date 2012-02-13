//
//  WCAlertsViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCAlertsViewController.h"

NSString *const WCAlertsWarnBeforeDeletingFontAndColorThemesKey = @"alertsWarnBeforeDeletingFontAndColorThemes";
NSString *const WCAlertsWarnBeforeDeletingKeyBindingCommandSetsKey = @"alertsWarnBeforeDeletingKeyBindingCommandSets";
NSString *const WCAlertsWarnBeforeDeletingBuildDefinesKey = @"alertsWarnBeforeDeletingBuildDefines";

@implementation WCAlertsViewController

#pragma mark *** Subclass Overrides ***
- (id)init {
	return [super initWithNibName:[self nibName] bundle:nil];
}

- (NSString *)nibName {
	return @"WCAlertsView";
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitstudio.advanced.alerts";
}

- (NSString *)label {
	return NSLocalizedString(@"Alerts", @"Alerts");
}

- (NSImage *)image {
	return [NSImage imageNamed:NSImageNameCaution];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCAlertsWarnBeforeDeletingFontAndColorThemesKey,[NSNumber numberWithBool:YES],WCAlertsWarnBeforeDeletingKeyBindingCommandSetsKey,[NSNumber numberWithBool:YES],WCAlertsWarnBeforeDeletingBuildDefinesKey, nil];
}

@end
