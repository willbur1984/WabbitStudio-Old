//
//  NSString+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSString+WCExtensions.h"
#import "RSDefines.h"

@implementation NSString (WCExtensions)
- (NSUInteger)lineNumberForRange:(NSRange)range; {
	__block NSUInteger lineNumber = 0;
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if (NSLocationInRange(range.location, enclosingRange)) {
			*stop = YES;
			return;
		}
		lineNumber++;
	}];
	
	return lineNumber;
}
- (NSRange)rangeForLineNumber:(NSUInteger)lineNumber; {
	__block NSRange range = NSEmptyRange;
	__block NSInteger lineNumberCopy = lineNumber;
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if ((--lineNumberCopy) < 0) {
			range = enclosingRange;
			*stop = YES;
		}
	}];
	
	return range;
}

- (NSRange)lineNumberRangeForRange:(NSRange)range; {
	__block NSRange lineNumberRange = NSEmptyRange;
	__block NSUInteger lineNumber = 0;
	__block BOOL hasSetRangeLocation = NO;
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if (!hasSetRangeLocation &&
			NSLocationInRange(range.location, enclosingRange)) {
			hasSetRangeLocation = YES;
			lineNumberRange.location = lineNumber; 
		}
		else if (NSMaxRange(enclosingRange) > NSMaxRange(range)) {
			if (lineNumberRange.length)
				lineNumberRange.length++;
			
			*stop = YES;
		}
		else if (hasSetRangeLocation)
			lineNumberRange.length++;
		
		lineNumber++;
	}];
	return lineNumberRange;
}
- (NSUInteger)numberOfLines; {
	__block NSUInteger retval = 0;
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		retval++;
	}];
	
	return retval;
}

- (NSString *)camelCaseString; {
	if ([self length] <= 1)
		return [self capitalizedString];
	return [[[self substringToIndex:1] capitalizedString] stringByAppendingString:[self substringFromIndex:1]];
}

- (NSUInteger)valueFromHexadecimalString; {
	NSString *string = [self stringByRemovingInvalidHexadecimalDigits];
	
	if (![string length])
		return 0;
	
	NSInteger index = [string length];
	NSUInteger total = 0, exponent = 0, base = 16;
	
	while (index > 0) {
		uint8_t value = HexValueForCharacter([string characterAtIndex:--index]);
		total += value * (NSUInteger)powf(base, exponent++);
	}
	return total;
}
- (NSUInteger)valueFromBinaryString; {
	NSString *string = [self stringByRemovingInvalidBinaryDigits];
	
	if (![string length])
		return 0;
	
	NSInteger index = [string length];
	NSUInteger total = 0, exponent = 0, base = 2;
	
	while (index > 0) {
		uint8_t value = HexValueForCharacter([string characterAtIndex:--index]);
		total += value * (NSUInteger)powf(base, exponent++);
	}
	return total;
}
- (NSUInteger)valueFromString; {
	NSString *string = [self stringByRemovingInvalidDigits];
	
	if (![string length])
		return 0;
	
	NSInteger index = [string length];
	NSUInteger total = 0, exponent = 0, base = 10;
	
	while (index > 0) {
		uint8_t value = ValueForCharacter([string characterAtIndex:--index]);
		total += value * (NSUInteger)powf(base, exponent++);
	}
	return total;
}

- (NSString *)stringByRemovingInvalidHexadecimalDigits; {
	static NSCharacterSet *hexadecimalDigits;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableCharacterSet *characterSet = [[[NSCharacterSet decimalDigitCharacterSet] mutableCopy] autorelease];
		[characterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFabcdef"]];
		hexadecimalDigits = [characterSet copy];
	});
	
	NSUInteger charIndex, bufferIndex, stringLength = [self length];
	unichar buffer[stringLength];
	
	for (charIndex = 0, bufferIndex = 0; charIndex < stringLength; charIndex++) {
		if ([hexadecimalDigits characterIsMember:[self characterAtIndex:charIndex]])
			buffer[bufferIndex++] = [self characterAtIndex:charIndex];
	}
	
	if (bufferIndex)
		return [[[NSString alloc] initWithCharacters:buffer length:bufferIndex] autorelease];
	return nil;
}
- (NSString *)stringByRemovingInvalidBinaryDigits; {
	static NSCharacterSet *binaryDigits;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		binaryDigits = [[NSCharacterSet characterSetWithCharactersInString:@"01"] retain];
	});
	
	NSUInteger charIndex, bufferIndex, stringLength = [self length];
	unichar buffer[stringLength];
	
	for (charIndex = 0, bufferIndex = 0; charIndex < stringLength; charIndex++) {
		if ([binaryDigits characterIsMember:[self characterAtIndex:charIndex]])
			buffer[bufferIndex++] = [self characterAtIndex:charIndex];
	}
	
	if (bufferIndex)
		return [[[NSString alloc] initWithCharacters:buffer length:bufferIndex] autorelease];
	return nil;
}
- (NSString *)stringByRemovingInvalidDigits; {
	static NSCharacterSet *digits;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		digits = [[NSCharacterSet decimalDigitCharacterSet] retain];
	});
	
	NSUInteger charIndex, bufferIndex, stringLength = [self length];
	unichar buffer[stringLength];
	
	for (charIndex = 0, bufferIndex = 0; charIndex < stringLength; charIndex++) {
		if ([digits characterIsMember:[self characterAtIndex:charIndex]])
			buffer[bufferIndex++] = [self characterAtIndex:charIndex];
	}
	
	if (bufferIndex)
		return [[[NSString alloc] initWithCharacters:buffer length:bufferIndex] autorelease];
	return nil;
}

// returns an autoreleased UUID String
+ (NSString *)UUIDString; {
	CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
	// turn out CFUUIDRef into a CFStringRef 
	CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUID);
	
	CFRelease(UUID);
	
	// toll free bridging is cool!
	return [(NSString *)UUIDString autorelease];
}
@end
