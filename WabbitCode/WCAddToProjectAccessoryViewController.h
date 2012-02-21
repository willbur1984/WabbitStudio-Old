//
//  WCAddToProjectAccessoryViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSUserDefaultsProvider.h"

extern NSString *const WCAddToProjectDestinationCopyItemsKey;

typedef enum _WCAddToProjectFolders {
	WCAddToProjectFoldersCreateGroups = 0,
	WCAddToProjectFoldersCreateFolderReferences = 1
	
} WCAddToProjectFolders;
extern NSString *const WCAddToProjectFoldersCreationKey;

@interface WCAddToProjectAccessoryViewController : NSViewController <RSUserDefaultsProvider>

@end
