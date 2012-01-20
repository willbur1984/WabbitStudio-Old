//
//  RSGlassGradientView.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSGlassGradientView.h"

@interface RSGlassGradientView ()
- (void)_commonInit;
@end

@implementation RSGlassGradientView

- (id)initWithFrame:(NSRect)frame {
    if (!(self = [super initWithFrame:frame]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[_fillGradient drawInRect:[self bounds] angle:270.0];
	
	if ([self shouldDrawTopEdge]) {
		[_topFillColor setFill];
		NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMaxY([self bounds])-1, NSWidth([self bounds]), 1.0));
	}
	
	if ([self shouldDrawBottomEdge]) {
		[_bottomFillColor setFill];
		NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
	}
	
	if ([self shouldDrawLeftEdge]) {
		[_bottomFillColor setFill];
		NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), 1.0, NSHeight([self bounds])));
	}
	
	if ([self shouldDrawRightEdge]) {
		[_bottomFillColor setFill];
		NSRectFill(NSMakeRect(NSMaxX([self bounds])-1, NSMinY([self bounds]), 1.0, NSHeight([self bounds])));
	}
}

@dynamic shouldDrawLeftEdge;
- (BOOL)shouldDrawLeftEdge {
	return NO;
}
@dynamic shouldDrawRightEdge;
- (BOOL)shouldDrawRightEdge {
	return NO;
}
@dynamic shouldDrawTopEdge;
- (BOOL)shouldDrawTopEdge {
	return YES;
}
@dynamic shouldDrawBottomEdge;
- (BOOL)shouldDrawBottomEdge {
	return NO;
}

- (void)_commonInit; {
	_fillGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:(253.0f / 255.0f) alpha:1],0.0,[NSColor colorWithCalibratedWhite:(242.0f / 255.0f) alpha:1],0.45454,[NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1],0.45454,[NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1],1.0,nil];
	_topFillColor = [[NSColor colorWithCalibratedWhite:(180.0/255.0) alpha:1.0] retain];
	_bottomFillColor = [[NSColor colorWithCalibratedWhite:(180.0/255.0) alpha:1.0] retain];
}
@end
