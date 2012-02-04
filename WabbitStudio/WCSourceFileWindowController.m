//
//  WCSourceFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidEndLiveResizeNotification object:[self window]];
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
- (void)_windowDidResize:(NSNotification *)note {
	[[[self document] sourceHighlighter] performHighlightingInVisibleRange];
}

@end
