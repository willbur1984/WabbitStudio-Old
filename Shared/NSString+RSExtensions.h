//
//  NSString+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (RSExtensions)
- (NSUInteger)lineNumberForRange:(NSRange)range;
- (NSRange)rangeForLineNumber:(NSUInteger)lineNumber;
- (NSRange)lineNumberRangeForRange:(NSRange)range;
- (NSUInteger)numberOfLines;

- (NSString *)stringByCapitalizingFirstLetter;

- (NSUInteger)valueFromHexadecimalString;
- (NSUInteger)valueFromBinaryString;
- (NSUInteger)valueFromString;

- (NSString *)stringByRemovingInvalidHexadecimalDigits;
- (NSString *)stringByRemovingInvalidBinaryDigits;
- (NSString *)stringByRemovingInvalidDigits;

+ (NSString *)UUIDString;

+ (NSString *)unixLineEndingString;
+ (NSString *)macOSLineEndingString;
+ (NSString *)windowsLineEndingString;

+ (NSString *)attachmentCharacterString;

+ (NSString *)tabUnicodeCharacterString;
+ (NSString *)returnUnicodeCharacterString;
+ (NSString *)spaceUnicodeCharacterString;
@end

static inline uint8_t RSHexValueForCharacter(unichar character) {
	switch (character) {
		case '0':
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		case 'a':
		case 'A':
			return 10;
		case 'b':
		case 'B':
			return 11;
		case 'c':
		case 'C':
			return 12;
		case 'd':
		case 'D':
			return 13;
		case 'e':
		case 'E':
			return 14;
		case 'f':
		case 'F':
			return 15;
		default:
			return 0;
	}
}

static inline uint8_t RSValueForCharacter(unichar character) {
	switch (character) {
		case '0':
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		default:
			return 0;
	}
}

static inline uint8_t RSBinaryValueForCharacter(unichar character) {
	switch (character) {
		case '0':
			return 0;
		case '1':
			return 1;
		default:
			return 0;
	}
}