//
//  WCScanSymbolsOperation.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCScanSymbolsOperation.h"
#import "WCSourceScanner.h"
#import "WCEquateSymbol.h"
#import "WCDefineSymbol.h"
#import "WCMacroSymbol.h"
#import "NDTrie.h"

@interface WCScanSymbolsOperation ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) NSString *string;
@end

@implementation WCScanSymbolsOperation

- (void)dealloc {
	[_sourceScanner release];
	[_string release];
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *symbols = [NSMutableArray arrayWithCapacity:0];
	NSRange searchRange = NSMakeRange(0, [[self string] length]);
	NSMutableDictionary *equateNames = [NSMutableDictionary dictionaryWithCapacity:0];
	NSMutableDictionary *labelNames = [NSMutableDictionary dictionaryWithCapacity:0];
	NSMutableDictionary *defineNames = [NSMutableDictionary dictionaryWithCapacity:0];
	NSMutableDictionary *macroNames = [NSMutableDictionary dictionaryWithCapacity:0];
	NDMutableTrie *completions = [NDMutableTrie trie];
	
	// equates
	[[WCSourceScanner equateRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange lineRange = [[self string] lineRangeForRange:[result range]];
		NSRange valueRange = NSMakeRange(NSMaxRange([result range]), NSMaxRange(lineRange)-NSMaxRange([result range]));
		NSString *value = [[self string] substringWithRange:valueRange];
		
		value = [value stringByReplacingOccurrencesOfString:@";+.*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
		value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if (![value length])
			return;
		
		NSString *name = [[self string] substringWithRange:[result rangeAtIndex:1]];
		WCEquateSymbol *equate = [WCEquateSymbol equateSymbolWithRange:[result rangeAtIndex:1] name:name value:value];
		NSMutableSet *equates = [equateNames objectForKey:[name lowercaseString]];
		
		if (!equates) {
			equates = [NSMutableSet setWithCapacity:0];
			[equateNames setObject:equates forKey:[name lowercaseString]];
		}
		
		[equate setSourceScanner:[self sourceScanner]];
		[equates addObject:equate];
		[completions setObject:equate forKey:[name lowercaseString]];
		[symbols addObject:equate];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	// labels
	[[WCSourceScanner labelRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *name = [[self string] substringWithRange:[result range]];
		
		// make sure it isn't already an equate
		if ([equateNames objectForKey:[name lowercaseString]])
			return;
		// ignore the temporary labels
		else if ([result range].length == 1 && [[self string] characterAtIndex:[result range].location] == '_')
			return;
		// ignore calls to macros
		else if (NSMaxRange([result range]) < [[self string] length] && [[self string] characterAtIndex:NSMaxRange([result range])] == '(')
			return;
		
		WCSourceSymbol *label = [WCSourceSymbol sourceSymbolOfType:WCSourceSymbolTypeLabel range:[result range] name:name];
		NSMutableSet *labels = [labelNames objectForKey:[name lowercaseString]];
		
		if (!labels) {
			labels = [NSMutableSet setWithCapacity:0];
			[labelNames setObject:labels forKey:[name lowercaseString]];
		}
		
		[label setSourceScanner:[self sourceScanner]];
		[labels addObject:label];
		[completions setObject:label forKey:[name lowercaseString]];
		[symbols addObject:label];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	// defines
	[[WCSourceScanner defineRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		// line range for our match
		NSRange lineRange = [[self string] lineRangeForRange:[result range]];
		// the rest of the line after the define name
		NSString *parensAndValue = [[self string] substringWithRange:NSMakeRange(NSMaxRange([result range]), NSMaxRange(lineRange)-NSMaxRange([result range]))];
		// check for matching parens and capture the enclosed arguments
		NSRegularExpression *parensRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\((.+?)\\)" options:0 error:NULL];
		NSTextCheckingResult *parensResult = [parensRegex firstMatchInString:parensAndValue options:0 range:NSMakeRange(0, [parensAndValue length])];
		NSString *value = (parensResult == nil)?parensAndValue:[parensAndValue substringWithRange:NSMakeRange(NSMaxRange([parensResult range]), [parensAndValue length]-NSMaxRange([parensResult range]))];
		
		value = [value stringByReplacingOccurrencesOfString:@";+.*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
		value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		NSString *name = [[self string] substringWithRange:[result rangeAtIndex:1]];
		WCDefineSymbol *define;
		
		// this define has a value
		if ([value length]) {
			// this define has arguments
			if (parensResult) {
				NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
				
				for (NSString *argument in [[parensAndValue substringWithRange:[parensResult rangeAtIndex:1]] componentsSeparatedByString:@","]) {
					NSString *trimmedArgument = [argument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
					if (![trimmedArgument length])
						continue;
					
					[arguments addObject:trimmedArgument];
				}
				
				if (![arguments count])
					arguments = nil;
				
				define = [WCDefineSymbol defineSymbolWithRange:[result rangeAtIndex:1] name:name value:value arguments:arguments];
			}
			// this define has no arguments
			else {
				define = [WCDefineSymbol defineSymbolWithRange:[result rangeAtIndex:1] name:name value:value];
			}
		}
		// this define has no value or arguments
		else {
			define = [WCDefineSymbol defineSymbolWithRange:[result rangeAtIndex:1] name:name];
		}
		
		NSMutableSet *defines = [defineNames objectForKey:[name lowercaseString]];
		
		if (!defines) {
			defines = [NSMutableSet setWithCapacity:0];
			[defineNames setObject:defines forKey:[name lowercaseString]];
		}
		
		[define setSourceScanner:[self sourceScanner]];
		[defines addObject:define];
		[completions setObject:define forKey:[name lowercaseString]];
		[symbols addObject:define];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	// macros
	[[WCSourceScanner macroRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange lineRange = [[self string] lineRangeForRange:[result range]];
		NSString *parens = [[self string] substringWithRange:NSMakeRange(NSMaxRange([result range]), NSMaxRange(lineRange)-NSMaxRange([result range]))];
		NSRegularExpression *parensRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\((.+?)\\)" options:0 error:NULL];
		NSTextCheckingResult *parensResult = [parensRegex firstMatchInString:parens options:0 range:NSMakeRange(0, [parens length])];
		NSString *value;
		
		if (parensResult) {
			NSTextCheckingResult *valueResult = [[NSRegularExpression regularExpressionWithPattern:@"(.+?)#endmacro" options:NSRegularExpressionDotMatchesLineSeparators error:NULL] firstMatchInString:[self string] options:0 range:NSMakeRange(NSMaxRange([result range])+NSMaxRange([parensResult range]), [[self string] length]-(NSMaxRange([result range])+NSMaxRange([parensResult range])))];
			
			if (!valueResult)
				return;
			
			value = [[self string] substringWithRange:[valueResult rangeAtIndex:1]];
		}
		else {
			NSTextCheckingResult *valueResult = [[NSRegularExpression regularExpressionWithPattern:@"(.+?)#endmacro" options:NSRegularExpressionDotMatchesLineSeparators error:NULL] firstMatchInString:[self string] options:NSRegularExpressionDotMatchesLineSeparators range:NSMakeRange(NSMaxRange([result range]), [[self string] length]-NSMaxRange([result range]))];
			
			if (!valueResult)
				return;
			
			value = [[self string] substringWithRange:[valueResult rangeAtIndex:1]];
		}
		
		value = [value stringByReplacingOccurrencesOfString:@";+.*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [value length])];
		value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![value length])
			return;
		
		NSString *name = [[self string] substringWithRange:[result rangeAtIndex:1]];
		WCMacroSymbol *macro;
		
		if (parensResult) {
			NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
			
			for (NSString *argument in [[parens substringWithRange:[parensResult rangeAtIndex:1]] componentsSeparatedByString:@","]) {
				NSString *trimmedArgument = [argument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
				if (![trimmedArgument length])
					continue;
				
				[arguments addObject:trimmedArgument];
			}
			
			if (![arguments count])
				arguments = nil;
			
			macro = [WCMacroSymbol macroSymbolWithRange:[result rangeAtIndex:1] name:[[self string] substringWithRange:[result rangeAtIndex:1]] value:value arguments:arguments];
		}
		else {
			macro = [WCMacroSymbol macroSymbolWithRange:[result rangeAtIndex:1] name:[[self string] substringWithRange:[result rangeAtIndex:1]] value:value];
		}
		
		NSMutableSet *macros = [macroNames objectForKey:[name lowercaseString]];
		
		if (!macros) {
			macros = [NSMutableSet setWithCapacity:0];
			[macroNames setObject:macros forKey:[name lowercaseString]];
		}
		
		[macro setSourceScanner:[self sourceScanner]];
		[macros addObject:macro];
		[completions setObject:macro forKey:[name lowercaseString]];
		[symbols addObject:macro];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	NSMutableSet *includes = [NSMutableSet setWithCapacity:0];
	
	[[WCSourceScanner includesRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *includesName = [[self string] substringWithRange:[result rangeAtIndex:1]];
		if ([includesName length])
			[includes addObject:includesName];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[symbols sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 rangeValue].location < [obj2 rangeValue].location)
			return NSOrderedAscending;
		else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
			return NSOrderedDescending;
		return NSOrderedSame;
	}]]];
	
	[[self sourceScanner] setSymbols:symbols];
	
	[symbols sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]]];
	
	[[self sourceScanner] setSymbolsSortedByName:symbols];
	
	[[self sourceScanner] setLabelNamesToLabelSymbols:labelNames];
	[[self sourceScanner] setEquateNamesToEquateSymbols:equateNames];
	[[self sourceScanner] setDefineNamesToDefineSymbols:defineNames];
	[[self sourceScanner] setMacroNamesToMacroSymbols:macroNames];
	[[self sourceScanner] setCompletions:completions];
	[[self sourceScanner] setIncludes:includes];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceScannerDidFinishScanningSymbolsNotification object:[self sourceScanner]];
	});
	
CLEANUP:
	[pool release];
}

+ (id)scanSymbolsOperationWithSourceScanner:(WCSourceScanner *)sourceScanner; {
	return [[[[self class] alloc] initWithSourceScanner:sourceScanner] autorelease];
}
- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner; {
	if (!(self = [super init]))
		return nil;
	
	_sourceScanner = [sourceScanner retain];
	_string = [[[sourceScanner textStorage] string] copy];
	
	return self;
}

@synthesize sourceScanner=_sourceScanner;
@synthesize string=_string;
@end
