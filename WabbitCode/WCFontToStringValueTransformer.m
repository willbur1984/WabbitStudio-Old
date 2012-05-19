//
//  WCFontToStringValueTransformer.m
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
