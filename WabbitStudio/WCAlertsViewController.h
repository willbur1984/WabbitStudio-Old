//
//  WCAlertsViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

extern NSString *const WCAlertsWarnBeforeDeletingFontAndColorThemesKey;
extern NSString *const WCAlertsWarnBeforeDeletingKeyBindingCommandSetsKey;
extern NSString *const WCAlertsWarnBeforeDeletingBuildDefinesKey;
extern NSString *const WCAlertsWarnBeforeDeletingBuildTargetsKey;
extern NSString *const WCAlertsWarnBeforeDeletingBuildIncludesKey;
extern NSString *const WCAlertsWarnBeforeDeletingBreakpointsKey;

@interface WCAlertsViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>

@end
