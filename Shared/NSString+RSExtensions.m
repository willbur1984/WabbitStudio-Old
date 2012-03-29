//
//  NSString+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "NSString+RSExtensions.h"
#import "RSDefines.h"

@implementation NSString (RSExtensions)
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

- (NSIndexSet *)lineNumbersForRange:(NSRange)range; {
	NSMutableIndexSet *lineNumbers = [NSMutableIndexSet indexSet];
	__block NSUInteger lineNumber = 0;
	
	if (!range.length && NSMaxRange(range) >= [self length]) {
		NSUInteger numberOfLines = [self numberOfLines];
		NSRange lineRange = [self lineRangeForRange:range];
		
		if (lineRange.length)
			numberOfLines--;
		
		[lineNumbers addIndex:numberOfLines];
	}
	else {
		[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if (NSLocationInRange(range.location, enclosingRange))
				[lineNumbers addIndex:lineNumber];
			else if (NSIntersectionRange(range, enclosingRange).length)
				[lineNumbers addIndex:lineNumber];
			else if (NSMaxRange(enclosingRange) > NSMaxRange(range)) {
				*stop = YES;
				
			}
			
			lineNumber++;
		}];
	}
	return [[lineNumbers copy] autorelease];
}

- (NSUInteger)numberOfLines; {
	__block NSUInteger retval = 0;
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		retval++;
	}];
	
	return retval;
}

- (NSString *)stringByCapitalizingFirstLetter; {
	if ([self length] <= 1)
		return [self capitalizedString];
	return [[[self substringToIndex:1] capitalizedString] stringByAppendingString:[self substringFromIndex:1]];
}
- (NSString *)stringByReplacingTabsWithSpaces; {
	return [self stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
}

- (NSUInteger)valueFromHexadecimalString; {
	NSString *string = [self stringByRemovingInvalidHexadecimalDigits];
	
	if (![string length])
		return 0;
	
	NSInteger index = [string length];
	NSUInteger total = 0, exponent = 0, base = 16;
	
	while (index > 0) {
		uint8_t value = RSHexValueForCharacter([string characterAtIndex:--index]);
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
		uint8_t value = RSHexValueForCharacter([string characterAtIndex:--index]);
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
		uint8_t value = RSValueForCharacter([string characterAtIndex:--index]);
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

- (NSString *)reverseString; {
	if ([self length] <= 1)
		return nil;
	
	NSUInteger stringLength = [self length];
	NSInteger stringIndex, reverseStringIndex;
	unichar *stringChars = calloc(sizeof(unichar), stringLength);
	unichar *reverseStringChars = calloc(sizeof(unichar), stringLength);
	
	[self getCharacters:stringChars];
	
	for (stringIndex=stringLength-1, reverseStringIndex=0; stringIndex>=0; stringIndex--, reverseStringIndex++)
		reverseStringChars[reverseStringIndex] = stringChars[stringIndex];
	
	free(stringChars);
	
	return [[[NSString alloc] initWithCharactersNoCopy:reverseStringChars length:stringLength freeWhenDone:YES] autorelease];
}

// returns an autoreleased UUID String
+ (NSString *)UUIDString; {
	CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
	// turn our CFUUIDRef into a CFStringRef 
	CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUID);
	
	CFRelease(UUID);
	
	// toll free bridging is cool!
	return [(NSString *)UUIDString autorelease];
}

+ (NSString *)unixLineEndingString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C",0x000A];
	});
	return retval;
}
+ (NSString *)macOSLineEndingString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C",0x000D];
	});
	return retval;
}
+ (NSString *)windowsLineEndingString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C%C",0x000D,0x000A];
	});
	return retval;
}

+ (NSString *)attachmentCharacterString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C",NSAttachmentCharacter];
	});	
	return retval;
}

+ (NSString *)tabUnicodeCharacterString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C",0x21E5];
	});	
	return retval;
}
+ (NSString *)returnUnicodeCharacterString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C",0x21B5];
	});	
	return retval;
}
+ (NSString *)spaceUnicodeCharacterString; {
	static NSString *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSString alloc] initWithFormat:@"%C",0x00B7];
	});	
	return retval;
}

@end
