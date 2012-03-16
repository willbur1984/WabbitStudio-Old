//
//  WCCalculatorWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 3/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class RSCalculator,RSLCDView;

@interface WCCalculatorWindowController : NSWindowController <NSWindowDelegate> {
	RSCalculator *_calculator;
	__weak RSLCDView *_LCDView;
	NSTimer *_FPSTimer;
	NSString *_statusString;
}
@property (readonly,nonatomic) RSCalculator *calculator;
@property (readonly,assign,nonatomic) RSLCDView *LCDView;
@property (readonly,copy,nonatomic) NSString *statusString;

- (id)initWithCalculator:(RSCalculator *)calculator;
@end
