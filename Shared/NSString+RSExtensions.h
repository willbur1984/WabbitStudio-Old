//
//  NSString+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/NSString.h>

@interface NSString (RSExtensions)
- (NSUInteger)lineNumberForRange:(NSRange)range;
- (NSRange)rangeForLineNumber:(NSUInteger)lineNumber;
- (NSIndexSet *)lineNumbersForRange:(NSRange)range;
- (NSUInteger)numberOfLines;

- (NSString *)stringByCapitalizingFirstLetter;
- (NSString *)stringByReplacingTabsWithSpaces;

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

- (NSString *)reverseString;
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
