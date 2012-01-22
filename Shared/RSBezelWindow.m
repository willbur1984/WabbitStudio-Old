//
//  RSBezelWindow.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSBezelWindow.h"

@implementation RSBezelWindow
#pragma mark *** Subclass Overrides ***
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if (!(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag]))
		return nil;
	
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	[self setHasShadow:YES];
	
	return self;
}
@end
