//
//  WEDebuggerWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,JUInspectorViewContainer,RSDisassemblyViewController,RSRegistersViewController,RSFlagsViewController,RSCPUViewController,RSMemoryMapViewController,RSInterruptsViewController,RSDisplayViewController,RSMemoryViewController;

@interface WEDebuggerWindowController : NSWindowController <NSWindowDelegate,NSSplitViewDelegate> {
	RSDisassemblyViewController *_disassemblyViewController;
	JUInspectorViewContainer *_inspectorViewContainer;
	RSRegistersViewController *_registersViewController;
	RSFlagsViewController *_flagsViewController;
	RSCPUViewController *_CPUViewController;
	RSMemoryMapViewController *_memoryMapViewController;
	RSInterruptsViewController *_interruptsViewController;
	RSDisplayViewController *_displayViewController;
	RSMemoryViewController *_memoryViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *disassemblyDummyView;
@property (readwrite,assign,nonatomic) IBOutlet NSScrollView *inspectorScrollView;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *inspectorSplitterHandleImageView;
@property (readwrite,assign,nonatomic) IBOutlet NSView *memoryDummyView;

@property (readonly,nonatomic) WECalculatorDocument *calculatorDocument;
@property (readonly,nonatomic) JUInspectorViewContainer *inspectorViewContainer;
@property (readonly,nonatomic) RSDisassemblyViewController *disassemblyViewController;
@property (readonly,nonatomic) RSRegistersViewController *registersViewController;
@property (readonly,nonatomic) RSFlagsViewController *flagsViewController;
@property (readonly,nonatomic) RSCPUViewController *CPUViewController;
@property (readonly,nonatomic) RSMemoryMapViewController *memoryMapViewController;
@property (readonly,nonatomic) RSInterruptsViewController *interruptsViewController;
@property (readonly,nonatomic) RSDisplayViewController *displayViewController;
@property (readonly,nonatomic) RSMemoryViewController *memoryViewController;

- (IBAction)step:(id)sender;
- (IBAction)stepOver:(id)sender;
- (IBAction)stepOut:(id)sender;

@end
