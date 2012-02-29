//
//  WCEditBreakpointViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBreakpointViewController.h"
#import "WCBreakpoint.h"
#import "RSHexadecimalFormatter.h"

@interface WCEditBreakpointViewController ()

@end

@implementation WCEditBreakpointViewController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_popover release];
	[_breakpoint release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCEditBreakpointView";
}

- (void)loadView {
	[super loadView];
	
	[[self formatter] setHexadecimalFormat:RSHexadecimalFormatUppercaseUnsignedShort];
}

#pragma mark NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification {
	[_popover setContentViewController:nil];
	[self setBreakpoint:nil];
}

+ (id)editBreakpointViewControllerWithBreakpoint:(WCBreakpoint *)breakpoint; {
	return [[[[self class] alloc] initWithBreakpoint:breakpoint] autorelease];
}
- (id)initWithBreakpoint:(WCBreakpoint *)breakpoint; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_breakpoint = [breakpoint retain];
	
	_popover = [[NSPopover alloc] init];
	[_popover setDelegate:self];
	[_popover setBehavior:NSPopoverBehaviorApplicationDefined];
	
	return self;
}

- (void)showEditBreakpointViewRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge; {
	[_popover setContentViewController:self];
	[_popover showRelativeToRect:rect ofView:view preferredEdge:preferredEdge];
}
- (void)hideEditBreakpointView; {
	[_popover performClose:nil];
}

- (IBAction)hideEditBreakpointView:(id)sender; {
	[self hideEditBreakpointView];
}

@synthesize formatter=_formatter;

@synthesize breakpoint=_breakpoint;

@end
