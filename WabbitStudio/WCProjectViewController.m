//
//  WCProjectViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectViewController.h"

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
	return nil;
}

@end
