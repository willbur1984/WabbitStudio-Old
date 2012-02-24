//
//  WEHardwareViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "RSPreferencesModule.h"
#import "RSCalculatorDelegate.h"

@class RSLCDView,RSCalculator;

@interface WEHardwareViewController : JAViewController <RSPreferencesModule,RSCalculatorDelegate,NSMenuDelegate>

@property (readwrite,assign,nonatomic) IBOutlet NSView *dummyLCDView;
@property (readwrite,assign,nonatomic) IBOutlet NSMenu *previewSourceMenu;
@property (readwrite,assign,nonatomic) IBOutlet NSPopUpButton *previewSourcePopUpButton;

@property (readwrite,assign,nonatomic) RSLCDView *LCDView;

@end
