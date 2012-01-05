//
//  NSColor+ContrastingLabelExtensions.m
//  ContrastingLabelColor
//
//  Created by Matt Gemmell on 16/08/2006.
//  Copyright 2006 Magic Aubergine. All rights reserved.
//

#import "NSColor+ContrastingLabelExtensions.h"


@implementation NSColor (ContrastingLabelExtensions)

- (NSColor *)contrastingLabelColor
{
    NSColor *rgbColor = [self colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    if (!rgbColor) { // happens if the colorspace couldn't be converted
        return [NSColor blackColor];
    }
    
    float avgGray = ([rgbColor redComponent] + [rgbColor greenComponent] + [rgbColor blueComponent]) / 3.0;
    
    return (avgGray >= 0.5) ? [NSColor blackColor] : [NSColor whiteColor];
}

@end
