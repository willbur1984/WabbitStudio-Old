//
//  WCEditBuildTargetDefinesFormatter.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetDefinesFormatter.h"

@implementation WCEditBuildTargetDefinesFormatter
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
