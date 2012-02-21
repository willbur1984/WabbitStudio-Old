//
//  WCGeneralViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSUserDefaultsProvider.h"
#import "RSPreferencesModule.h"

typedef enum _WCGeneralOnStartup {
	WCGeneralOnStartupShowNewProjectWindow = 0,
	WCGeneralOnStartupOpenMostRecentProject = 1,
	WCGeneralOnStartupOpenUntitledDocument = 2,
	WCGeneralOnStartupDoNothing = 3
	
} WCGeneralOnStartup;
extern NSString *const WCGeneralOnStartupKey;

@interface WCGeneralViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>

@end
