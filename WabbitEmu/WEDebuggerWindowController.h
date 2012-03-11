//
//  WEDebuggerWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,RSDisassemblyViewController,RSRegistersViewController,RSFlagsViewController,JUInspectorViewContainer;

@interface WEDebuggerWindowController : NSWindowController <NSWindowDelegate> {
	RSDisassemblyViewController *_disassemblyViewController;
	RSRegistersViewController *_registersViewController;
	RSFlagsViewController *_flagsViewController;
	JUInspectorViewContainer *_inspectorViewContainer;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *disassemblyDummyView;
@property (readwrite,assign,nonatomic) IBOutlet NSScrollView *inspectorScrollView;

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,nonatomic) RSDisassemblyViewController *disassemblyViewController;
@property (readonly,nonatomic) RSRegistersViewController *registersViewController;
@property (readonly,nonatomic) RSFlagsViewController *flagsViewController;
@property (readonly,nonatomic) JUInspectorViewContainer *inspectorViewContainer;

- (IBAction)step:(id)sender;
- (IBAction)stepOver:(id)sender;
- (IBAction)stepOut:(id)sender;

@end
