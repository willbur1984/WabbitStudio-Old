//
//  WEDebuggerWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,RSDisassemblyViewController;

@interface WEDebuggerWindowController : NSWindowController <NSWindowDelegate> {
	RSDisassemblyViewController *_disassemblyViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *disassemblyDummyView;

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,nonatomic) RSDisassemblyViewController *disassemblyViewController;

@end
