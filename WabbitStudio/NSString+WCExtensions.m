//
//  NSString+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSString+WCExtensions.h"
#import "RSDefines.h"
#import "WCSourceScanner.h"

@implementation NSString (WCExtensions)
- (NSRange)symbolRangeForRange:(NSRange)range; {
	if (![self length])
		return NSNotFoundRange;
	
	__block NSRange symbolRange = NSNotFoundRange;
	NSRange lineRange = [self lineRangeForRange:range];
	
	[[WCSourceScanner symbolRegularExpression] enumerateMatchesInString:self options:0 range:lineRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInOrEqualToRange(range.location, [result range])) {
			symbolRange = [result range];
			*stop = YES;
		}
	}];
	return symbolRange;
}
@end
