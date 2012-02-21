//
//  WCFontToStringValueTransformer.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFontToStringValueTransformer.h"

static NSFont *defaultFont;

@implementation WCFontToStringValueTransformer
#pragma mark *** Subclass Overrides ***
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultFont = [[NSFont fontWithName:@"Menlo" size:11.0] retain];
	});
}

+ (Class)transformedValueClass {
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation {
	return YES;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSFont class]]) {
		return [NSString stringWithFormat:@"%@ - %.1f",[value displayName],[value pointSize]];
	}
	return [self transformedValue:defaultFont];
}
- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]]) {
		NSArray *parts = [value componentsSeparatedByString:@"-"];
		if ([parts count] < 2)
			return defaultFont;
		
		NSString *name = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		NSScanner *scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
		CGFloat size;
		
		if (![scanner scanDouble:&size])
			return defaultFont;
		
		NSFont *retval = [NSFont fontWithName:name size:size];
		if (!retval)
			return defaultFont;
		return retval;
	}
	return defaultFont;
}
@end
