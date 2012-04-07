//
//  WCFilesViewController.h
//  WabbitStudio
//
//  Created by William Towe on 4/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

typedef enum _WCFilesOpenFilesWith {
	WCFilesOpenFilesWithDoubleClick = 0,
	WCFilesOpenFilesWithSingleClick = 1
} WCFilesOpenFilesWith;

extern NSString *const WCFilesOpenFilesWithKey;

@interface WCFilesViewController : NSViewController <RSUserDefaultsProvider,RSPreferencesModule>

@end
