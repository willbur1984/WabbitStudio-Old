//
//  WCGeneralViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCGeneralViewController.h"

NSString *const WCGeneralOnStartupKey = @"generalOnStartup";

@implementation WCGeneralViewController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	return self;
}

- (NSString *)nibName {
	return @"WCGeneralView";
}

#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitstudio.general";
}

- (NSString *)label {
	return NSLocalizedString(@"General", @"General");
}

- (NSImage *)image {
	return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WCGeneralOnStartupShowNewProjectWindow],WCGeneralOnStartupKey, nil];;
}

@end
