//
//  RSToolTipPresentationView.m
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
