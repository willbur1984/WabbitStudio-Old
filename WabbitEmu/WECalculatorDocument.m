//
//  WECalculatorDocument.m
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

#import "WECalculatorDocument.h"
#import "RSCalculator.h"
#import "WECalculatorWindowController.h"
#import "WEDebuggerWindowController.h"

@interface WECalculatorDocument ()
@property (readwrite,retain,nonatomic) RSCalculator *calculator;
@property (readonly,nonatomic) WEDebuggerWindowController *debuggerWindowController;
@end

@implementation WECalculatorDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator release];
	[super dealloc];
}

- (void)makeWindowControllers {
	WECalculatorWindowController *windowController = [[[WECalculatorWindowController alloc] initWithCalculatorDocument:self] autorelease];
	
	[windowController setShouldCloseDocument:YES];
	
	[self addWindowController:windowController];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	[self setHasUndoManager:NO];
	[self setUndoManager:nil];
	
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	RSCalculator *calculator = [[[RSCalculator alloc] initWithRomOrSavestateURL:url error:outError] autorelease];
	
	if (!calculator)
		return NO;
	
	[calculator setDelegate:self];
	[self setCalculator:calculator];
	
	return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	
	return YES;
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (void)calculator:(RSCalculator *)calculator didLoadRomOrSavestateURL:(NSURL *)romOrSavestateURL; {
	[self setFileURL:romOrSavestateURL];
	
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:romOrSavestateURL];
}

- (void)handleBreakpointHitForCalculator:(RSCalculator *)calculator {
	[self showDebugger:nil];
}

- (IBAction)showDebugger:(id)sender; {
	[[self debuggerWindowController] showWindow:nil];
}

@synthesize calculator=_calculator;
@dynamic debuggerWindowController;
- (WEDebuggerWindowController *)debuggerWindowController {
	for (id windowController in [self windowControllers]) {
		if ([windowController isKindOfClass:[WEDebuggerWindowController class]])
			return windowController;
	}
	
	WEDebuggerWindowController *windowController = [[[WEDebuggerWindowController alloc] init] autorelease];
	
	[self addWindowController:windowController];
	
	[[self calculator] setRunning:NO];
	[[self calculator] setDebugging:YES];
	
	return windowController;
}

@end
