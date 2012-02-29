//
//  WEDebuggerWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument;

@interface WEDebuggerWindowController : NSWindowController <NSWindowDelegate>

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;

@end
