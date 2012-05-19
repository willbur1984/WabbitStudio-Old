//
//  RSGlassGradientView.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RSGlassGradientView.h"

@interface RSGlassGradientView ()
- (void)_commonInit;
@end

@implementation RSGlassGradientView
#pragma mark *** Subclass Overrides ***
- (id)initWithFrame:(NSRect)frame {
    if (!(self = [super initWithFrame:frame]))
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
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark *** Public Methods ***

#pragma mark Properties
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
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	_fillGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:(253.0f / 255.0f) alpha:1],0.0,[NSColor colorWithCalibratedWhite:(242.0f / 255.0f) alpha:1],0.45454,[NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1],0.45454,[NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1],1.0,nil];
	_topFillColor = [[NSColor colorWithCalibratedWhite:(180.0/255.0) alpha:1.0] retain];
	_bottomFillColor = [[NSColor colorWithCalibratedWhite:(180.0/255.0) alpha:1.0] retain];
}
@end
