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
#import "RSCPUViewController.h"
#import "RSMemoryMapViewController.h"
#import "RSInterruptsViewController.h"
#import "RSDisplayViewController.h"
#import "RSMemoryViewController.h"
#import "RSStackViewController.h"

static NSString *const WEDebuggerToolbarStepItemIdentifier = @"WEDebuggerToolbarStepItemIdentifier";
static NSString *const WEDebuggerToolbarStepOutItemIdentifier = @"WEDebuggerToolbarStepOutItemIdentifier";
static NSString *const WEDebuggerToolbarStepOverItemIdentifier = @"WEDebuggerToolbarStepOverItemIdentifier";

static NSString *const WEDebuggerWindowToolbarItemIdentifier = @"WEDebuggerWindowToolbarItemIdentifier";

@interface WEDebuggerWindowController ()

@end

@implementation WEDebuggerWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_stackViewController release];
	[_memoryViewController release];
	[_displayViewController release];
	[_interruptsViewController release];
	[_memoryMapViewController release];
	[_CPUViewController release];
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
	
	// toolbar
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:WEDebuggerWindowToolbarItemIdentifier] autorelease];
	
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setSizeMode:NSToolbarSizeModeRegular];
	[toolbar setDelegate:self];
	
#ifndef DEBUG
	[toolbar setAutosavesConfiguration:YES];
#endif
	
	[[self window] setToolbar:toolbar];
	
	// disassembly view
	[[[self disassemblyViewController] view] setFrameSize:[[self disassemblyDummyView] frame].size];
	[[[self disassemblyDummyView] superview] replaceSubview:[self disassemblyDummyView] with:[[self disassemblyViewController] view]];
	
	// memory view
	[[[self memoryViewController] view] setFrameSize:[[self memoryDummyView] frame].size];
	[[[self memoryDummyView] superview] replaceSubview:[self memoryDummyView] with:[[self memoryViewController] view]];
	
	// stack view
	[[[self stackViewController] view] setFrameSize:[[self stackDummyView] frame].size];
	[[[self stackDummyView] superview] replaceSubview:[self stackDummyView] with:[[self stackViewController] view]];
	
	// inspector view
	[[self inspectorScrollView] setAutoresizesSubviews:YES];
	[[self inspectorScrollView] setDocumentView:[self inspectorViewContainer]];
	
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self registersViewController] view] expanded:YES];
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self flagsViewController] view] expanded:YES];
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self CPUViewController] view] expanded:NO];
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self memoryMapViewController] view] expanded:NO];
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self interruptsViewController] view] expanded:NO];
	[[self inspectorViewContainer] addInspectorView:(JUInspectorView *)[[self displayViewController] view] expanded:NO];
}
#pragma mark NSToolbarDelegate
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	return [NSArray arrayWithObjects:WEDebuggerToolbarStepItemIdentifier,WEDebuggerToolbarStepOutItemIdentifier,WEDebuggerToolbarStepOverItemIdentifier,NSToolbarSpaceItemIdentifier,NSToolbarFlexibleSpaceItemIdentifier, nil];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,WEDebuggerToolbarStepItemIdentifier,WEDebuggerToolbarStepOutItemIdentifier,WEDebuggerToolbarStepOverItemIdentifier,NSToolbarFlexibleSpaceItemIdentifier, nil];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	
	if ([itemIdentifier isEqualToString:WEDebuggerToolbarStepItemIdentifier]) {
		[item setLabel:NSLocalizedString(@"Step", @"Step")];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Step"]];
		[item setAction:@selector(step:)];
	}
	else if ([itemIdentifier isEqualToString:WEDebuggerToolbarStepOutItemIdentifier]) {
		[item setLabel:NSLocalizedString(@"Step Out", @"Step Out")];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Step Out"]];
		[item setAction:@selector(stepOut:)];
	}
	else if ([itemIdentifier isEqualToString:WEDebuggerToolbarStepOverItemIdentifier]) {
		[item setLabel:NSLocalizedString(@"Step Over", @"Step Over")];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Step Over"]];
		[item setAction:@selector(stepOver:)];
	}
	
	return item;
}

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
	if ([splitView isVertical] && [[splitView subviews] lastObject] == view)
		return NO;
	else if (![splitView isVertical] && [[splitView subviews] objectAtIndex:0] == view)
		return NO;
	return YES;
}

static CGFloat kLeftSubviewMinimumWidth = 350.0;
static CGFloat kRightSubviewMinimumWidth = 200.0;
static CGFloat kTopSubviewMinimumWidth = 200.0;
static CGFloat kBottomSubviewMinimumWidth = 125.0;

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
	if ([splitView isVertical])
		return proposedMaximumPosition-kRightSubviewMinimumWidth;
	return proposedMaximumPosition-kBottomSubviewMinimumWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
	if ([splitView isVertical])
		return proposedMinimumPosition+kLeftSubviewMinimumWidth;
	return proposedMinimumPosition+kTopSubviewMinimumWidth;
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
	if ([splitView isVertical])
		return [splitView convertRect:[[self inspectorSplitterHandleImageView] bounds] fromView:[self inspectorSplitterHandleImageView]];
	return NSZeroRect;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
	if ([self memoryAndStackSplitView] == splitView)
		return [splitView maxPossiblePositionOfDividerAtIndex:dividerIndex];
	return proposedPosition;
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
@synthesize inspectorSplitterHandleImageView=_inspectorSplitterHandleImageView;
@synthesize memoryDummyView=_memoryDummyView;
@synthesize stackDummyView=_stackDummyView;
@synthesize memoryAndStackSplitView=_memoryAndStackSplitView;

@dynamic calculatorDocument;
- (WECalculatorDocument *)calculatorDocument {
	return (WECalculatorDocument *)[self document];
}
@dynamic inspectorViewContainer;
- (JUInspectorViewContainer *)inspectorViewContainer {
	if (!_inspectorViewContainer) {
		_inspectorViewContainer = [[JUInspectorViewContainer alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
		[_inspectorViewContainer setAutoresizingMask:NSViewWidthSizable];
	}
	return _inspectorViewContainer;
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
@dynamic CPUViewController;
- (RSCPUViewController *)CPUViewController {
	if (!_CPUViewController)
		_CPUViewController = [[RSCPUViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _CPUViewController;
}
@dynamic memoryMapViewController;
- (RSMemoryMapViewController *)memoryMapViewController {
	if (!_memoryMapViewController)
		_memoryMapViewController = [[RSMemoryMapViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _memoryMapViewController;
}
@dynamic interruptsViewController;
- (RSInterruptsViewController *)interruptsViewController {
	if (!_interruptsViewController)
		_interruptsViewController = [[RSInterruptsViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _interruptsViewController;
}
@dynamic displayViewController;
- (RSDisplayViewController *)displayViewController {
	if (!_displayViewController)
		_displayViewController = [[RSDisplayViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _displayViewController;
}
@dynamic memoryViewController;
- (RSMemoryViewController *)memoryViewController {
	if (!_memoryViewController)
		_memoryViewController = [[RSMemoryViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _memoryViewController;
}
@dynamic stackViewController;
- (RSStackViewController *)stackViewController {
	if (!_stackViewController)
		_stackViewController = [[RSStackViewController alloc] initWithCalculator:[[self calculatorDocument] calculator]];
	return _stackViewController;
}

@end
