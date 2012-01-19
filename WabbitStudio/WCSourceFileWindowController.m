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
#import "UKXattrMetadataStore.h"
#import "RSDefines.h"
#import "WCSourceTextView.h"

@interface WCSourceFileWindowController ()

@end

@implementation WCSourceFileWindowController

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
	
	NSString *windowFrame = [UKXattrMetadataStore stringForKey:WCSourceFileDocumentWindowFrameKey atPath:[[[self document] fileURL] path] traverseLink:NO];
	if (windowFrame)
		[[self window] setFrameFromString:windowFrame];
	
	NSView *contentView = [[self window] contentView];
	
	[[[self sourceTextViewController] view] setFrame:[contentView frame]];
	[contentView addSubview:[[self sourceTextViewController] view]];
	
	NSRange selectedRange = NSRangeFromString([UKXattrMetadataStore stringForKey:WCSourceFileDocumentSelectedRangeKey atPath:[[[self document] fileURL] path] traverseLink:NO]);
	
	if (!NSEqualRanges(NSEmptyRange, selectedRange) &&
		NSMaxRange(selectedRange) < [[[[self sourceTextViewController] textView] string] length]) {
		
		[[[self sourceTextViewController] textView] setSelectedRange:selectedRange];
		[[[self sourceTextViewController] textView] scrollRangeToVisible:selectedRange];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
}

- (void)windowWillClose:(NSNotification *)notification {
	[[self sourceTextViewController] performCleanup];
}

@dynamic sourceTextViewController;
- (WCStandardSourceTextViewController *)sourceTextViewController {
	if (!_sourceTextViewController) {
		_sourceTextViewController = [[WCStandardSourceTextViewController alloc] initWithSourceFileDocument:[self document]];
	}
	return _sourceTextViewController;
}

- (void)_windowDidResize:(NSNotification *)note {
	//[[[self document] sourceHighlighter] performHighlightingInVisibleRange];
}

@end
