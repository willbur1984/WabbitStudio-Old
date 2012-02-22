//
//  RSSkinView.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSSkinView.h"
#import "RSCalculator.h"

@implementation RSSkinView

- (void)dealloc {
	[_calculator release];
	[super dealloc];
}

- (BOOL)isFlipped {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[[self calculator] skinImage] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}

- (id)initWithFrame:(NSRect)frameRect calculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self setAutoresizingMask:NSViewNotSizable];
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;

@end
