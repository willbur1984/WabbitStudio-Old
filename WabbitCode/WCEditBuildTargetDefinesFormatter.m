//
//  WCEditBuildTargetDefinesFormatter.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCEditBuildTargetDefinesFormatter.h"

@implementation WCEditBuildTargetDefinesFormatter
#pragma mark *** Subclass Overrides ***
- (NSString *)stringForObjectValue:(id)obj {
	if ([obj isKindOfClass:[NSString class]])
		return obj;
	return nil;
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error {
	if (![string length]) {
		*obj = NSLocalizedString(@"NEW_DEFINE", @"NEW_DEFINE");
		return YES;
	}
	
	static NSCharacterSet *legalDefineChars;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableCharacterSet *temp = [[[NSCharacterSet letterCharacterSet] copy] autorelease];
		
		[temp formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
		
		legalDefineChars = [temp copy];
	});
	
	NSMutableString *temp = [NSMutableString stringWithCapacity:[string length]];
	NSScanner *scanner = [NSScanner scannerWithString:string];
	
	while (![scanner isAtEnd]) {
		NSString *legalString;
		if ([scanner scanCharactersFromSet:legalDefineChars intoString:&legalString])
			[temp appendString:legalString];
		else
			[scanner setScanLocation:[scanner scanLocation]+1];
	}
	
	if (![temp length]) {
		*obj = NSLocalizedString(@"NEW_DEFINE", @"NEW_DEFINE");
		return YES;
	}
	
	*obj = [temp uppercaseString];
	
	return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error {
	*partialStringPtr = [*partialStringPtr uppercaseString];
	return NO;
}
@end
