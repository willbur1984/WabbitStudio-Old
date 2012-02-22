//
//  WECalculatorWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,RSLCDView;

@interface WECalculatorWindowController : NSWindowController <NSWindowDelegate> {
	__weak WECalculatorDocument *_calculatorDocument;
	__weak RSLCDView *_LCDView;
}

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,assign,nonatomic) RSLCDView *LCDView;

- (id)initWithCalculatorDocument:(WECalculatorDocument *)calculatorDocument;
@end
