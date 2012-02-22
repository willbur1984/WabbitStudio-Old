//
//  WECalculatorWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WECalculatorWindowController.h"
#import "WECalculatorDocument.h"
#import "RSCalculator.h"
#import "RSLCDView.h"
#import "RSLCDViewManager.h"

@interface WECalculatorWindowController ()
@property (readwrite,assign,nonatomic) RSLCDView *LCDView;
@end

@implementation WECalculatorWindowController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WECalculatorWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSView *contentView = [[self window] contentView];
	NSRect lcdViewFrame = [contentView frame];
	
	lcdViewFrame.size.height -= [[self window] contentBorderThicknessForEdge:NSMinYEdge];
	lcdViewFrame.origin.y += [[self window] contentBorderThicknessForEdge:NSMinYEdge];
	
	RSLCDView *lcdView = [[[RSLCDView alloc] initWithFrame:lcdViewFrame calculator:[[self calculatorDocument] calculator]] autorelease];
	
	[contentView addSubview:lcdView];
	[[RSLCDViewManager sharedManager] addLCDView:lcdView];
	
	[self setLCDView:lcdView];
}

- (void)windowWillClose:(NSNotification *)notification {
	[[RSLCDViewManager sharedManager] removeLCDView:[self LCDView]];
}

- (id)initWithCalculatorDocument:(WECalculatorDocument *)calculatorDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_calculatorDocument = calculatorDocument;
	
	return self;
}

@synthesize calculatorDocument=_calculatorDocument;
@synthesize LCDView=_LCDView;

@end
