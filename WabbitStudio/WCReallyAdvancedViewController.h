//
//  WCReallyAdvancedViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

typedef enum _WCReallyAdvancedJumpBarSortItemsBy {
	WCReallyAdvancedJumpBarSortItemsByLocation = 0,
	WCReallyAdvancedJumpBarSortItemsByName = 1
	
} WCReallyAdvancedJumpBarSortItemsBy;
extern NSString *const WCReallyAdvancedJumpBarSortItemsByKey;
extern NSString *const WCReallyAdvancedJumpBarShowFileAndLineNumberKey;

@interface WCReallyAdvancedViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@end
