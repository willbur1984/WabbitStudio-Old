//
//  RSFindBarView.m
//  WabbitEdit
//
//  Created by William Towe on 12/30/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSFindBarView.h"

@implementation RSFindBarView

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *fillGradient;
	static NSColor *bottomFillColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:236.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:197.0/255.0 alpha:1.0]];
		bottomFillColor = [[NSColor colorWithCalibratedWhite:135.0/255.0 alpha:1.0] retain];
	});
	
	[fillGradient drawInRect:[self bounds] angle:270.0];
	
	[bottomFillColor setFill];
	NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
}

@end
