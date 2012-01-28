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

@interface WCProjectViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>

@end
