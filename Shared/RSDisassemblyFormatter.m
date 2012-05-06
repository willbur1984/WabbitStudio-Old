//
//  RSDisassemblyFormatter.m
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSDisassemblyFormatter.h"

@implementation RSDisassemblyFormatter
- (NSString *)stringForObjectValue:(id)obj {
	return obj;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)defaultAttributes {
	static NSRegularExpression *operationalCodeRegex;
	static NSRegularExpression *registerRegex;
	static NSRegularExpression *conditionalRegisterRegex;
	static NSRegularExpression *numberRegex;
	static NSRegularExpression *binaryNumberRegex;
	static NSRegularExpression *hexadecimalNumberRegex;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		operationalCodeRegex = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:adc|add|and|bit|call|ccf|cpdr|cpd|cpir|cpi|cpl|cp|daa|dec|di|djnz|ei|exx|ex|halt|im|inc|indr|ind|inir|ini|in|jp|jr|lddr|ldd|ldir|ldi|ld|neg|nop|or|otdr|otir|outd|outi|out|pop|push|res|reti|retn|ret|rla|rlca|rlc|rld|rl|rra|rrca|rrc|rrd|rr|rst|sbc|scf|set|sla|sll|sra|srl|sub|xor)\\b" options:NSRegularExpressionAnchorsMatchLines error:NULL];
		registerRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:\\baf')|(?:\\b(?:ixh|iyh|ixl|iyl|sp|af|pc|bc|de|hl|ix|iy|a|f|b|c|d|e|h|l|r|i)\\b)" options:0 error:NULL];
		conditionalRegisterRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:call|jp|jr|ret)\\s+(nz|nv|nc|po|pe|c|p|m|n|z|v)\\b" options:0 error:NULL];
		numberRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:^|(?<=[^$%]\\b))[0-9]+\\b" options:0 error:NULL];
		binaryNumberRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:%[01]+\\b)|(?:(?:^|(?<=[^$%]\\b))[01]+(?:b|B)\\b)" options:0 error:NULL];
		hexadecimalNumberRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:\\$[A-Fa-f0-9]+\\b)|(?:(?:^|(?<=[^$%]\\b))[0-9a-fA-F]+(?:h|H)\\b)" options:0 error:NULL];
	});
	
	NSMutableAttributedString *attrbutedString = [[[NSMutableAttributedString alloc] initWithString:[self stringForObjectValue:obj] attributes:defaultAttributes] autorelease];
	
	[registerRegex enumerateMatchesInString:[attrbutedString string] options:0 range:NSMakeRange(0, [attrbutedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attrbutedString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:[result range]];
	}];
	
	[conditionalRegisterRegex enumerateMatchesInString:[attrbutedString string] options:0 range:NSMakeRange(0, [attrbutedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attrbutedString addAttribute:NSForegroundColorAttributeName value:[NSColor cyanColor] range:[result rangeAtIndex:1]];
	}];
	
	[operationalCodeRegex enumerateMatchesInString:[attrbutedString string] options:0 range:NSMakeRange(0, [attrbutedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attrbutedString applyFontTraits:NSBoldFontMask range:[result range]];
		[attrbutedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:[result range]];
	}];
	
	[numberRegex enumerateMatchesInString:[attrbutedString string] options:0 range:NSMakeRange(0, [attrbutedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attrbutedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:[result range]];
	}];
	
	[binaryNumberRegex enumerateMatchesInString:[attrbutedString string] options:0 range:NSMakeRange(0, [attrbutedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attrbutedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.75 alpha:1.0] range:[result range]];
	}];
	
	[hexadecimalNumberRegex enumerateMatchesInString:[attrbutedString string] options:0 range:NSMakeRange(0, [attrbutedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attrbutedString addAttribute:NSForegroundColorAttributeName value:[NSColor magentaColor] range:[result range]];
	}];
	
	return attrbutedString;
}
@end
