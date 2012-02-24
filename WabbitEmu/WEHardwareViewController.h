//
//  WEHardwareViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"

@class RSLCDView,RSCalculator;

@interface WEHardwareViewController : NSViewController <RSPreferencesModule,NSMenuDelegate>

@property (readwrite,assign,nonatomic) IBOutlet NSView *dummyLCDView;
@property (readwrite,assign,nonatomic) IBOutlet NSMenu *previewSourceMenu;

@property (readwrite,assign,nonatomic) RSLCDView *LCDView;

@end
