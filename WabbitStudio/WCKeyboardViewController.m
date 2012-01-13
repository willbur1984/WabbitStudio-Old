//
//  WCKeyboardViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyboardViewController.h"

NSString *const WCKeyboardUseTabToNavigateArgumentPlaceholdersKey = @"keyboardUseTabToNavigateArgumentPlaceholders";
NSString *const WCKeyboardHomeAndEndKeysBehaviorKey = @"keyboardHomeAndEndKeysBehavior";

@implementation WCKeyboardViewController

#pragma mark *** Subclass Overrides ***
- (id)init {
	return [super initWithNibName:[self nibName] bundle:nil];
}

- (NSString *)nibName {
	return @"WCKeyboardView";
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitstudio.advanced.keyboard";
}

- (NSString *)label {
	return NSLocalizedString(@"Keyboard", @"Keyboard");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"Keyboard"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCKeyboardUseTabToNavigateArgumentPlaceholdersKey,[NSNumber numberWithUnsignedInteger:WCKeyboardHomeAndEndKeysBehaviorScrollToBeginningAndEndOfDocument],WCKeyboardHomeAndEndKeysBehaviorKey, nil];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
@synthesize initialFirstResponder=_initialFirstResponder;

@end
