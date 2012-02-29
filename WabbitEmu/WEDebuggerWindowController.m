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

@interface WEDebuggerWindowController ()

@end

@implementation WEDebuggerWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
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
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
	[[[self calculatorDocument] calculator] setDebugging:NO];
	[[[self calculatorDocument] calculator] setRunning:YES];
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@dynamic calculatorDocument;
- (WECalculatorDocument *)calculatorDocument {
	return (WECalculatorDocument *)[self document];
}

@end
