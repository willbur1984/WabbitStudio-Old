//
//  NSString+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSString+WCExtensions.h"
#import "RSDefines.h"
#import "WCSourceScanner.h"
#import "WCFileTemplate.h"

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

- (NSString *)stringByReplacingFileTemplatePlaceholdersWithValuesDictionary:(NSDictionary *)valuesDictionary; {
	NSMutableString *temp = [[self mutableCopy] autorelease];
	
	// replace the file name placeholder
	[temp replaceOccurrencesOfString:WCFileTemplateFileNamePlaceholder withString:[valuesDictionary objectForKey:WCFileTemplateFileNameValueKey] options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	// replace the project name placeholder
	[temp replaceOccurrencesOfString:WCFileTemplateProjectNamePlaceholder withString:[valuesDictionary objectForKey:WCFileTemplateProjectNameValueKey] options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	// replace the full username placeholder
	[temp replaceOccurrencesOfString:WCFileTemplateFullUserNamePlaceholder withString:NSFullUserName() options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	// replace the date placeholder
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	});
	
	[temp replaceOccurrencesOfString:WCFileTemplateDatePlaceholder withString:[dateFormatter stringFromDate:[NSDate date]] options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	if ([[valuesDictionary objectForKey:WCFileTemplateIncludeFileNamesValueKey] count]) {
		// replace the include file names placeholder
		NSMutableString *includeFileNamesString = [NSMutableString stringWithCapacity:0];
		
		for (NSString *includeFileName in [valuesDictionary objectForKey:WCFileTemplateIncludeFileNamesValueKey])
			[includeFileNamesString appendFormat:NSLocalizedString(@"#include \"%@\"\n", @"include file name format string"),includeFileName];
		
		// delete the last newline
		if ([includeFileNamesString length])
			[includeFileNamesString deleteCharactersInRange:NSMakeRange([includeFileNamesString length]-1, 1)];
		
		[temp replaceOccurrencesOfString:WCFileTemplateIncludeFileNamesPlaceholder withString:includeFileNamesString options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	}
	else {
		[temp replaceOccurrencesOfString:[WCFileTemplateIncludeFileNamesPlaceholder stringByAppendingFormat:@"\n"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	}
	
	return [[temp copy] autorelease];
}
@end
