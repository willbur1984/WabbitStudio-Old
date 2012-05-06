//
//  WEDebuggerWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSWindowController.h>

@class WECalculatorDocument,JUInspectorViewContainer,RSDisassemblyViewController,RSRegistersViewController,RSFlagsViewController,RSCPUViewController,RSMemoryMapViewController,RSInterruptsViewController,RSDisplayViewController,RSMemoryViewController,RSStackViewController;

@interface WEDebuggerWindowController : NSWindowController <NSWindowDelegate,NSSplitViewDelegate,NSToolbarDelegate> {
	RSDisassemblyViewController *_disassemblyViewController;
	JUInspectorViewContainer *_inspectorViewContainer;
	RSRegistersViewController *_registersViewController;
	RSFlagsViewController *_flagsViewController;
	RSCPUViewController *_CPUViewController;
	RSMemoryMapViewController *_memoryMapViewController;
	RSInterruptsViewController *_interruptsViewController;
	RSDisplayViewController *_displayViewController;
	RSMemoryViewController *_memoryViewController;
	RSStackViewController *_stackViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *disassemblyDummyView;
@property (readwrite,assign,nonatomic) IBOutlet NSScrollView *inspectorScrollView;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *inspectorSplitterHandleImageView;
@property (readwrite,assign,nonatomic) IBOutlet NSView *memoryDummyView;
@property (readwrite,assign,nonatomic) IBOutlet NSView *stackDummyView;
@property (readwrite,assign,nonatomic) IBOutlet NSSplitView *memoryAndStackSplitView;

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
@property (readonly,nonatomic) RSStackViewController *stackViewController; 

- (IBAction)step:(id)sender;
- (IBAction)stepOver:(id)sender;
- (IBAction)stepOut:(id)sender;
- (IBAction)toggleNormalBreakpoint:(id)sender;

@end
