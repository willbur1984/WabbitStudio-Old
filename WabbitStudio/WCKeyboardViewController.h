//
//  WCKeyboardViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

extern NSString *const WCKeyboardUseTabToNavigateArgumentPlaceholdersKey;

typedef enum _WCKeyboardHomeAndEndKeysBehavior {
	WCKeyboardHomeAndEndKeysBehaviorScrollToBeginningAndEndOfDocument = 0,
	WCKeyboardHomeAndEndKeysBehaviorScrollToBeginningAndEndOfCurrentLine = 1
	
} WCKeyboardHomeAndEndKeysBehavior;
extern NSString *const WCKeyboardHomeAndEndKeysBehaviorKey;

@interface WCKeyboardViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@end
