//
//  RSNavigatorControlCell.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSNavigatorControlCell.h"

@interface RSNavigatorControlCell ()
- (void)_commonInit;
@end

@implementation RSNavigatorControlCell
#pragma mark *** Subclass Overrides ***
- (id)initImageCell:(NSImage *)image {
	if (!(self = [super initImageCell:image]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (NSInteger)nextState {
    return self.state;
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)controlView {
    if (self.state == NSOnState) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        
        // light vertical gradient
        static NSGradient *gradient = nil;
        if (!gradient) {
            NSColor *color1 = [NSColor colorWithCalibratedWhite:0.7 alpha:0.0];
            NSColor *color2 = [NSColor colorWithCalibratedWhite:0.7 alpha:5.0];
            CGFloat loactions[] = {0.0f, 0.5f, 1.0f};
            gradient = [[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:color1, color2, color1, nil] atLocations:loactions colorSpace:[NSColorSpace genericGrayColorSpace]];
        }
        [gradient drawInRect:frame angle:-90.0f];
        
        
        // shadow on the left border
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = NSMakeSize(1.0f, 0.0f);
        shadow.shadowBlurRadius = 2.0f;
        shadow.shadowColor = [NSColor darkGrayColor];
        [shadow set];
        
        // not visible color
        [[NSColor redColor] set];
        
        CGFloat radius = 50.0;
        
        NSPoint center = NSMakePoint(NSMinX(frame) - radius, NSMidY(frame));
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:center];
        [path appendBezierPathWithArcWithCenter:center
                                         radius:radius
                                     startAngle:-90.0f 
                                       endAngle:90.0f];
        [path closePath];
        [path fill];
        
        // shadow of the right border
        shadow.shadowOffset = NSMakeSize(-1.0f, 0.0f);
        [shadow set];
        
        center = NSMakePoint(NSMaxX(frame) + radius, NSMidY(frame));
        path = [NSBezierPath bezierPath];
        [path moveToPoint:center];
        [path appendBezierPathWithArcWithCenter:center
                                         radius:radius
                                     startAngle:90.0f 
                                       endAngle:270.0f];
        [path closePath];
        [path fill];
        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
    
    [self drawInteriorWithFrame:frame inView:controlView];
}
 
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	[self setHighlightsBy:NSContentsCellMask];
	[self setShowsStateBy:NSNoCellMask];
}
@end
