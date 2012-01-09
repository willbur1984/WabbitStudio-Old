//
//  WCSourceFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceFileWindowController.h"
#import "WCSourceTextViewController.h"
#import "WCSourceFileDocument.h"
#import "WCSplitView.h"
#import "NSEvent+RSExtensions.h"
#import "WCSourceHighlighter.h"
#import "NSTextView+WCExtensions.h"
#import "WCSourceTextView.h"

@interface WCSourceFileWindowController ()
@property (readonly,nonatomic) WCSourceTextViewController *sourceTextViewController;
@property (readonly,nonatomic) WCSplitView *splitView;
@property (readonly,nonatomic) WCSourceTextViewController *bottomSourceTextViewController;
@end

@implementation WCSourceFileWindowController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_bottomSourceTextViewController release];
	[_splitView release];
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

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(toggleEditorSplitView:)) {
		if ([[_splitView subviews] count])
			[menuItem setTitle:NSLocalizedString(@"Close Editor Split", @"Close Editor Split")];
		else if (([menuItem keyEquivalentModifierMask] & NSAlternateKeyMask) != 0)
			[menuItem setTitle:NSLocalizedString(@"Split Editor Vertically", @"Split Editor Vertically")];
		else
			[menuItem setTitle:NSLocalizedString(@"Split Editor", @"Split Editor")];
	}
	return YES;
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
	proposedEffectiveRect.size.height = 5.0;
	return proposedEffectiveRect;
}

- (IBAction)toggleEditorSplitView:(id)sender; {
	NSView *contentView = [[[self sourceTextViewController] view] superview];
	// close the split view
	if ([[contentView subviews] count] &&
		[[[contentView subviews] objectAtIndex:0] isKindOfClass:[NSSplitView class]]) {
		
		[[self splitView] removeFromSuperviewWithoutNeedingDisplay];
		[[[self sourceTextViewController] view] removeFromSuperviewWithoutNeedingDisplay];
		[[[self bottomSourceTextViewController] view] removeFromSuperviewWithoutNeedingDisplay];
		
		[[[self sourceTextViewController] view] setFrame:[contentView frame]];
		[contentView addSubview:[[self sourceTextViewController] view]];
		
		[[[self sourceTextViewController] sourceHighlighter] performHighlightingInRange:[[[self sourceTextViewController] textView] visibleRange]];
	}
	// create the split view and add the second source text view controller's view to it
	else {
		BOOL verticalSplit = [NSEvent isOptionKeyPressed];
		if (verticalSplit) {
			[[self splitView] setDividerStyle:NSSplitViewDividerStylePaneSplitter];
			[[self splitView] setVertical:YES];
		}
		else {
			[[self splitView] setDividerStyle:NSSplitViewDividerStyleThin];
			[[self splitView] setVertical:NO];
		}
		
		[[self splitView] setFrame:[contentView frame]];
		
		[[[self sourceTextViewController] view] removeFromSuperviewWithoutNeedingDisplay];
		
		[contentView addSubview:[self splitView]];
		
		[[self splitView] addSubview:[[self sourceTextViewController] view]];
		[[self splitView] addSubview:[[self bottomSourceTextViewController] view]];
		
		if (verticalSplit) {
			
		}
		else {
			
		}
		
		[[[self sourceTextViewController] textView] scrollRangeToVisible:[[[self sourceTextViewController] textView] selectedRange]];
		[[[self bottomSourceTextViewController] textView] setSelectedRange:[[[self sourceTextViewController] textView] selectedRange]];
		[[[self bottomSourceTextViewController] textView] scrollRangeToVisible:[[[self sourceTextViewController] textView] selectedRange]];
		[[[self sourceTextViewController] sourceHighlighter] performHighlightingInVisibleRange];
	}
	
	[[self window] makeFirstResponder:[[self sourceTextViewController] textView]];
}

@dynamic sourceTextViewController;
- (WCSourceTextViewController *)sourceTextViewController {
	if (!_sourceTextViewController) {
		_sourceTextViewController = [[WCSourceTextViewController alloc] initWithSourceFileDocument:[self document]];
	}
	return _sourceTextViewController;
}
@dynamic splitView;
- (WCSplitView *)splitView {
	if (!_splitView) {
		_splitView = [[WCSplitView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth([[[self window] contentView] frame]), NSHeight([[[self window] contentView] frame]))];
		[_splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMinYMargin];
		//[_splitView setAutoresizesSubviews:YES];
		[_splitView setDelegate:self];
		[_splitView setDividerColor:[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0]];
	}
	return _splitView;
}
@dynamic bottomSourceTextViewController;
- (WCSourceTextViewController *)bottomSourceTextViewController {
	if (!_bottomSourceTextViewController) {
		_bottomSourceTextViewController = [[WCSourceTextViewController alloc] initWithSourceFileDocument:[self document]];
	}
	return _bottomSourceTextViewController;
}

@end
