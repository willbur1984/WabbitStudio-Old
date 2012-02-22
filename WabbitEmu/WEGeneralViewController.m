//
//  WEGeneralViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEGeneralViewController.h"

@interface WEGeneralViewController ()

@end

@implementation WEGeneralViewController

- (NSString *)nibName {
	return @"WEGeneralView";
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	return self;
}

- (NSString *)identifier; {
	return @"org.wabbitemu.preferences.general";
}
- (NSString *)label; {
	return NSLocalizedString(@"General", @"General");
}
- (NSImage *)image; {
	return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
