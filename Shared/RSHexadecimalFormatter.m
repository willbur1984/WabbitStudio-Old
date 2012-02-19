//
//  RSHexadecimalFormatter.m
//  WabbitStudio
//
//  Created by William Towe on 8/18/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

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
