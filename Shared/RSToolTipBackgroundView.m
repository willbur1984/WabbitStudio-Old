//
//  RSToolTipPresentationView.m
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSToolTipBackgroundView.h"


@implementation RSToolTipBackgroundView
#pragma mark *** Subclass Overrides ***
- (void)drawRect:(NSRect)dirtyRect {
	static NSGradient *fillGradient;
	static NSGradient *borderGradient;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:250.0/255.0 green:245.0/255.0 blue:180.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:215.0/255.0 green:210.0/255.0 blue:150.0/255.0 alpha:1.0]];
		borderGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:105.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:61.0/255.0 alpha:1.0]];
	});
	
	[borderGradient drawInRect:[self bounds] angle:270.0];
	//[fillGradient drawInRect:NSInsetRect([self bounds], 1.0, 1.0) angle:270.0];
	[[NSColor colorWithCalibratedRed:250.0/255.0 green:247.0/255.0 blue:182.0/255.0 alpha:1.0] setFill];
	NSRectFill(NSInsetRect([self bounds], 1.0, 1.0));
}

@end
