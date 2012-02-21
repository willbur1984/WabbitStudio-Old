//
//  WCProjectViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

typedef enum _WCProjectAutoSave {
	WCProjectAutoSaveAlways = 0,
	WCProjectAutoSavePrompt = 1,
	WCProjectAutoSaveNever = 2
	
} WCProjectAutoSave;
extern NSString *const WCProjectAutoSaveKey;

typedef enum _WCProjectBuildProductsLocation {
	WCProjectBuildProductsLocationProjectFolder = 0,
	WCProjectBuildProductsLocationCustom = 1
	
} WCProjectBuildProductsLocation;
extern NSString *const WCProjectBuildProductsLocationKey;
extern NSString *const WCProjectBuildProductsLocationCustomKey;

@interface WCProjectViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>

- (IBAction)chooseCustomBuildProductsLocation:(id)sender;

@end
