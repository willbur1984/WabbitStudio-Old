//
//  WCSourceFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSourceFileWindowController.h"
#import "WCStandardSourceTextViewController.h"
#import "WCSourceFileDocument.h"
#import "WCSourceHighlighter.h"
#import "RSDefines.h"
#import "WCSourceTextView.h"

@interface WCSourceFileWindowController ()

@end

@implementation WCSourceFileWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_sourceTextViewController release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	
	return self;
}

- (NSString *)windowNibName { 
	return @"WCSourceFileWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSView *contentView = [[self window] contentView];
	
	[[[self sourceTextViewController] view] setFrame:[contentView frame]];
	[contentView addSubview:[[self sourceTextViewController] view]];
}

- (void)windowWillClose:(NSNotification *)notification {
	[[self sourceTextViewController] performCleanup];
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@dynamic sourceTextViewController;
- (WCStandardSourceTextViewController *)sourceTextViewController {
	if (!_sourceTextViewController) {
		_sourceTextViewController = [[WCStandardSourceTextViewController alloc] initWithSourceFileDocument:[self document]];
	}
	return _sourceTextViewController;
}
#pragma mark *** Private Methods ***

#pragma mark Notifications

@end
