//
//  WCEditorViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

@interface WCEditorViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@end
