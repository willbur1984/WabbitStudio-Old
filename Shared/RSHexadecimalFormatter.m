//
//  RSHexadecimalFormatter.m
//  WabbitStudio
//
//  Created by William Towe on 8/18/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSHexadecimalFormatter.h"
#import "NSString+RSExtensions.h"

@interface RSHexadecimalFormatter ()
- (RSInputFormat)_inputFormatForString:(NSString *)string;
@end

@implementation RSHexadecimalFormatter
#pragma mark *** Subclass Overrides ***
static const uint32_t defaultRetval = 0;
- (NSString *)stringForObjectValue:(id)object {
	if ([object isKindOfClass:[NSNumber class]]) {
		switch ([self hexadecimalFormat]) {
			case RSHexadecimalFormatDefault:
				return [NSString stringWithFormat:@"%x",[object unsignedIntValue]];
			case RSHexadecimalFormatUnsignedChar:
				return [NSString stringWithFormat:@"%02x",[object unsignedIntValue]];
			case RSHexadecimalFormatUnsignedShort:
				return [NSString stringWithFormat:@"%04x",[object unsignedIntValue]];
			case RSHexadecimalFormatUnsignedInt:
				return [NSString stringWithFormat:@"%08x",[object unsignedIntValue]];
			case RSHexadecimalFormatUppercaseUnsignedChar:
				return [NSString stringWithFormat:@"%02X",[object unsignedIntValue]];
			case RSHexadecimalFormatUppercaseUnsignedInt:
				return [NSString stringWithFormat:@"%08X",[object unsignedIntValue]];
			case RSHexadecimalFormatUppercaseUnsignedShort:
				return [NSString stringWithFormat:@"%04X",[object unsignedIntValue]];
			case RSHexadecimalFormatUppercaseDefault:
				return [NSString stringWithFormat:@"%X",[object unsignedIntValue]];
			default:
				break;
		}
	}
	return [NSString stringWithFormat:@"%x",defaultRetval];
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)errorDescription {
	if (![string length]) {
		*object = [NSNumber numberWithUnsignedInt:defaultRetval];
		return YES;
	}
	
	NSString *newString;
	RSInputFormat inputFormat = [self _inputFormatForString:string];
	switch (inputFormat) {
		case RSInputFormatBaseSixteen:
			newString = [string stringByRemovingInvalidHexadecimalDigits];
			break;
		case RSInputFormatBaseTen:
			newString = [string stringByRemovingInvalidDigits];
			break;
		case RSInputFormatBaseTwo:
			newString = [string stringByRemovingInvalidBinaryDigits];
			break;
		default:
			newString = string;
			break;
	}
	
	if (![newString length]) {
		*object = [NSNumber numberWithUnsignedInt:defaultRetval];
		return YES;
	}
	
	uint32_t value;
	switch (inputFormat) {
		case RSInputFormatBaseSixteen:
			value = (uint32_t)[newString valueFromHexadecimalString];
			break;
		case RSInputFormatBaseTen:
			value = (uint32_t)[newString valueFromString];
			break;
		case RSInputFormatBaseTwo:
			value = (uint32_t)[newString valueFromBinaryString];
			break;
		default:
			value = 0;
			break;
	}
	
	*object = [NSNumber numberWithUnsignedInt:value];
	return YES;
}
#pragma mark Properties
@synthesize hexadecimalFormat=_hexadecimalFormat;
@synthesize inputFormat=_inputFormat;
#pragma mark *** Private Methods ***
- (RSInputFormat)_inputFormatForString:(NSString *)string; {
	// at least two characters are required to provide an explicit format
	if ([string length] >= 2) {
		unichar firstChar = [string characterAtIndex:0];
		if (firstChar == '$')
			return RSInputFormatBaseSixteen;
		else if (firstChar == '%')
			return RSInputFormatBaseTwo;
		
		unichar lastChar = [string characterAtIndex:[string length]-1];
		if (lastChar == 'h' || lastChar == 'H')
			return RSInputFormatBaseSixteen;
		else if (lastChar == 'b' || lastChar == 'B')
			return RSInputFormatBaseTwo;
		
	}
	return [self inputFormat];
}

@end
