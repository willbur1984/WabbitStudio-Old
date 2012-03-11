//
//  WEDebuggerWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/28/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEDebuggerWindowController.h"
#import "WECalculatorDocument.h"
#import "RSCalculator.h"
#import "RSDisassemblyViewController.h"
#import "RSRegistersViewController.h"
#import "JUInspectorViewContainer.h"
#import "RSFlagsViewController.h"

@interface WEDebuggerWindowController ()

@end

@implementation WEDebuggerWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_flagsViewController release];
	[_registersViewController release];
	[_inspectorViewContainer release];
	[_disassemblyViewController release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	return self;
}

- (NSString *)windowNibName {
	return @"WEDebuggerWindow";
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - Debugger", @"debugger window title format string"),displayName];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[[self disassemblyViewController] view] setFrameSize:[[self disassemblyDummyView] frame].size];
	[[[self disassemblyDummyView] superview] replaceSubview:[self disassemblyDummyView] with:[[self disassemblyViewController] view]];
	
	[[self inspectorScrollView] setAutoresizesSubviews:YES];
	[[self inspectorScrollView] setDocumentView:[self inspectorViewContainer]];
	
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self registersViewController] view] expanded:YES];
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self flagsViewController] view] expanded:YES];
}

#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
	[[[self calculatorDocument] calculator] setDebugging:NO];
	[[[self calculatorDocument] calculator] setRunning:YES];
}
#pragma mark *** Public Methods ***

#pragma mark IBActions
- (IBAction)step:(id)sender; {
	[[[self calculatorDocument] calculator] step];
}
- (IBAction)stepOver:(id)sender; {
	[[[self calculatorDocument] calculator] stepOver];
}
- (IBAction)stepOut:(id)sender; {
	[[[self calculatorDocument] calculator] stepOut];
}

#pragma mark Properties
@synthesize disassemblyDummyView=_disassemblyDummyView;
@synthesize inspectorScrollView=_inspectorScrollView;

@dynamic calculatorDocument;
- (WECalculatorDocument *)calculatorDocument {
	return (WECalculatorDocument *)[self document];
}
@dynamic disassemblyViewController;
- (RSDisassemblyViewController *)disassemblyViewController {
	if (!_disassemblyViewController)
		_disassemblyViewController = [[RSDisassemblyViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _disassemblyViewController;
}
@dynamic registersViewController;
- (RSRegistersViewController *)registersViewController {
	if (!_registersViewController)
		_registersViewController = [[RSRegistersViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _registersViewController;
}
@dynamic flagsViewController;
- (RSFlagsViewController *)flagsViewController {
	if (!_flagsViewController)
		_flagsViewController = [[RSFlagsViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _flagsViewController;
}
@dynamic inspectorViewContainer;
- (JUInspectorViewContainer *)inspectorViewContainer {
	if (!_inspectorViewContainer) {
		_inspectorViewContainer = [[JUInspectorViewContainer alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
		[_inspectorViewContainer setAutoresizingMask:NSViewWidthSizable];
	}
	return _inspectorViewContainer;
}

@end
