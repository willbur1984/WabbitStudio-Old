//
//  WCScanTokensOperation.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCScanTokensOperation.h"
#import "WCSourceScanner.h"
#import "WCSourceToken.h"
#import "WCNumberToken.h"
#import "NSPointerArray+WCExtensions.h"

@interface WCScanTokensOperation ()
@property (readonly,nonatomic) WCSourceScanner *scanner;
@property (readonly,nonatomic) NSString *string;
@end

@implementation WCScanTokensOperation
- (void)dealloc {
	[_scanner release];
	[_string release];
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:0];
	NSPointerArray *commentRanges = [NSPointerArray pointerArrayForRanges];
	NSPointerArray *multilineCommentRanges = [NSPointerArray pointerArrayForRanges];
	NSPointerArray *stringRanges = [NSPointerArray pointerArrayForRanges];
	NSRange searchRange = NSMakeRange(0, [[self string] length]);
	
	[[WCSourceScanner multilineCommentRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [result range];
		
		[multilineCommentRanges addPointer:&range];
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeComment range:range name:nil]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner commentRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [result range];
		
		if (NSLocationInRange(range.location, [multilineCommentRanges rangeForRange:range]))
			return;
		
		[commentRanges addPointer:&range];
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeComment range:range name:nil]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner stringRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [result range];
		
		if (NSLocationInRange(range.location, [multilineCommentRanges rangeForRange:range]) ||
			NSLocationInRange(range.location, [commentRanges rangeForRange:range]))
			return;
		
		[stringRanges addPointer:&range];
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeString range:range name:[[self string] substringWithRange:range]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner mnemonicRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeMneumonic range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner registerRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeRegister range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner directiveRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeDirective range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner numberRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCNumberToken sourceTokenOfType:WCSourceTokenTypeNumber range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner binaryRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCNumberToken sourceTokenOfType:WCSourceTokenTypeBinary range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner hexadecimalRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCNumberToken sourceTokenOfType:WCSourceTokenTypeHexadecimal range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner preProcessorRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypePreProcessor range:[result range] name:[[self string] substringWithRange:[result range]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[[WCSourceScanner conditionalRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
			NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
			return;
		
		[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeConditional range:[result rangeAtIndex:1] name:[[self string] substringWithRange:[result rangeAtIndex:1]]]];
	}];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	[tokens sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 rangeValue].location < [obj2 rangeValue].location)
			return NSOrderedAscending;
		else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
			return NSOrderedDescending;
		return NSOrderedSame;
	}]]];
	
	[[self scanner] setTokens:tokens];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceScannerDidFinishScanningNotification object:[self scanner]];
	});
	
CLEANUP:
	[pool release];
}

+ (id)scanTokensOperationWithScanner:(WCSourceScanner *)scanner; {
	return [[[[self class] alloc] initWithScanner:scanner] autorelease];
}
- (id)initWithScanner:(WCSourceScanner *)scanner; {
	if (!(self = [super init]))
		return nil;
	
	_scanner = [scanner retain];
	_string = [[[scanner textStorage] string] copy];
	
	return self;
}

@synthesize scanner=_scanner;
@synthesize string=_string;
@end
