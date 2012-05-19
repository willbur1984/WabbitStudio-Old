//
//  WCColorToStringValueTransformer.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCColorToStringValueTransformer.h"

static NSColor *defaultColor;

@implementation WCColorToStringValueTransformer
#pragma mark *** Subclass Overrides ***
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultColor = [[NSColor blackColor] retain];
	});
}

+ (Class)transformedValueClass {
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation {
	return YES;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSColor class]]) {
		if (![[value colorSpace] isEqualTo:[NSColorSpace genericRGBColorSpace]])
			value = [value colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
		
		CGFloat red, green, blue, alpha;
		
		[value getRed:&red green:&green blue:&blue alpha:&alpha];
		
		return [NSString stringWithFormat:@"%.3f %.3f %.3f",red,green,blue];
	}
	return [self transformedValue:defaultColor];
}
- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]]) {
		NSArray *components = [value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([components count] < 3)
			return defaultColor;
		
		CGFloat red, green, blue, alpha = 1.0;
		NSScanner *scanner = [NSScanner scannerWithString:[components objectAtIndex:0]];
		
		if (![scanner scanDouble:&red])
			red = 0.0;
		else if (red > 1.0)
			red = red/255.0;
		scanner = [NSScanner scannerWithString:[components objectAtIndex:1]];
		if (![scanner scanDouble:&green])
			green = 0.0;
		else if (green > 1.0)
			green = green/255.0;
		scanner = [NSScanner scannerWithString:[components objectAtIndex:2]];
		if (![scanner scanDouble:&blue])
			blue = 0.0;
		else if (blue > 1.0)
			blue = blue/255.0;
		return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
	}
	return [NSColor blackColor];
}
@end
