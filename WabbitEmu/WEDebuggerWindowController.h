//
//  WEDebuggerWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,RSDisassemblyViewController,RSRegistersViewController,RSFlagsViewController,RSCPUViewController,JUInspectorViewContainer;

@interface WEDebuggerWindowController : NSWindowController <NSWindowDelegate,NSSplitViewDelegate> {
	RSDisassemblyViewController *_disassemblyViewController;
	RSRegistersViewController *_registersViewController;
	RSFlagsViewController *_flagsViewController;
	RSCPUViewController *_CPUViewController;
	JUInspectorViewContainer *_inspectorViewContainer;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *disassemblyDummyView;
@property (readwrite,assign,nonatomic) IBOutlet NSScrollView *inspectorScrollView;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *inspectorSplitterHandleImageView;

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,nonatomic) RSDisassemblyViewController *disassemblyViewController;
@property (readonly,nonatomic) RSRegistersViewController *registersViewController;
@property (readonly,nonatomic) RSFlagsViewController *flagsViewController;
@property (readonly,nonatomic) RSCPUViewController *CPUViewController;
@property (readonly,nonatomic) JUInspectorViewContainer *inspectorViewContainer;

- (IBAction)step:(id)sender;
- (IBAction)stepOver:(id)sender;
- (IBAction)stepOut:(id)sender;

@end
