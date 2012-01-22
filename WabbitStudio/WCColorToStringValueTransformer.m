//
//  WCColorToStringValueTransformer.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
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
