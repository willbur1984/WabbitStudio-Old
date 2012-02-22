//
//  WEPreferencesWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEPreferencesWindowController.h"
#import "WEGeneralViewController.h"

@implementation WEPreferencesWindowController

+ (NSString *)windowNibName {
	return @"WEPreferencesWindow";
}

- (void)setupViewControllers {
	[self addViewController:[[[WEGeneralViewController alloc] init] autorelease]];
}

@end
