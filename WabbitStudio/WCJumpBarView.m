//
//  WCJumpBarView.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCJumpBarView.h"

@interface WCJumpBarView ()
- (void)_commonInit;
@end

@implementation WCJumpBarView

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_fillGradient release];
	[_alternateFillGradient release];
	[_bottomFillColor release];
	[_alternateBottomFillColor release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
    if (!(self = [super initWithFrame:frame]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	if ([[self window] isKeyWindow])
		[_fillGradient drawInRect:[self bounds] angle:90.0];
	else
		[_alternateFillGradient drawInRect:[self bounds] angle:90.0];
	
	if ([[self window] isKeyWindow])
		[_bottomFillColor setFill];
	else
		[_alternateBottomFillColor setFill];
	NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResignKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidBecomeKeyObservingToken];
	
	if (newWindow) {
		[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
		[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
	}
}

- (void)_commonInit; {
	_fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:174.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:211.0/255.0 alpha:1.0]];
	_alternateFillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:209.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:244.0/255.0 alpha:1.0]];
	_bottomFillColor = [[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0] retain];
	_alternateBottomFillColor = [[NSColor colorWithCalibratedWhite:109.0/255.0 alpha:1.0] retain];
}

@end
