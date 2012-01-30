//
//  RSToolTipWindow.m
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSToolTipPanel.h"


@implementation RSToolTipPanel
#pragma mark *** Subclass Overrides ***
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if (!(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag]))
		return nil;
	
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	[self setFloatingPanel:YES];
	[self setIgnoresMouseEvents:YES];
	[self setHasShadow:YES];
	[self setLevel:NSPopUpMenuWindowLevel];
	
	return self;
}

@end
