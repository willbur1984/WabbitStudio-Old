//
//  WECalculatorWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,RSLCDView,RSCalculator;

@interface WECalculatorWindowController : NSWindowController <NSWindowDelegate> {
	__unsafe_unretained WECalculatorDocument *_calculatorDocument;
	__unsafe_unretained RSLCDView *_LCDView;
	NSTimer *_FPSTimer;
	NSString *_statusString;
}

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,assign,nonatomic) RSLCDView *LCDView;
@property (readonly,copy,nonatomic) NSString *statusString;

- (id)initWithCalculatorDocument:(WECalculatorDocument *)calculatorDocument;
@end
