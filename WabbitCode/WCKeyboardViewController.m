//
//  WCKeyboardViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
	return @"org.revsoft.wabbitcode.advanced.keyboard";
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
