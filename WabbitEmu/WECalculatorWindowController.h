//
//  WECalculatorWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,RSLCDView,RSCalculator;

@interface WECalculatorWindowController : NSWindowController <NSWindowDelegate> {
	__weak WECalculatorDocument *_calculatorDocument;
	__weak RSLCDView *_LCDView;
	NSTimer *_FPSTimer;
	NSString *_statusString;
}

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,assign,nonatomic) RSLCDView *LCDView;
@property (readonly,copy,nonatomic) NSString *statusString;

- (id)initWithCalculatorDocument:(WECalculatorDocument *)calculatorDocument;
@end
