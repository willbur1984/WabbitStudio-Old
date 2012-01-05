//
//  NSString+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSString+WCExtensions.h"

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

- (NSString *)camelCaseString; {
	if ([self length] <= 1)
		return [self capitalizedString];
	return [[[self substringToIndex:1] capitalizedString] stringByAppendingString:[self substringFromIndex:1]];
}
@end
