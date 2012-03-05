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
			[includeFileNamesString appendFormat:@"%@\n",includeFileName];
		
		// delete the last newline
		if ([includeFileNamesString length])
			[includeFileNamesString deleteCharactersInRange:NSMakeRange([includeFileNamesString length]-1, 1)];
		
		[temp replaceOccurrencesOfString:WCFileTemplateIncludeFileNamesPlaceholder withString:includeFileNamesString options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	}
	else {
		[temp replaceOccurrencesOfString:WCFileTemplateIncludeFileNamesPlaceholder withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	}
	
	return [[temp copy] autorelease];
}
@end
