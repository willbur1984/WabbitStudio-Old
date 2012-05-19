//
//  WCScanTokensOperation.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
#pragma mark *** Subclass Overrides ***
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
	BOOL isFinished = NO;
	
	while (![self isCancelled] && !isFinished) {
		[[WCSourceScanner multilineCommentRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSRange range = [result range];
			
			[multilineCommentRanges addPointer:&range];
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeComment range:range name:nil]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner commentRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSRange range = [result range];
			
			if (NSLocationInRange(range.location, [multilineCommentRanges rangeForRange:range]))
				return;
			
			[commentRanges addPointer:&range];
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeComment range:range name:nil]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner stringRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSRange range = [result range];
			
			if (NSLocationInRange(range.location, [multilineCommentRanges rangeForRange:range]) ||
				NSLocationInRange(range.location, [commentRanges rangeForRange:range]))
				return;
			
			[stringRanges addPointer:&range];
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeString range:range name:[[self string] substringWithRange:range]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner mnemonicRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeMneumonic range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner registerRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeRegister range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner directiveRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeDirective range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner numberRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCNumberToken sourceTokenOfType:WCSourceTokenTypeNumber range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner binaryRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCNumberToken sourceTokenOfType:WCSourceTokenTypeBinary range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner hexadecimalRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCNumberToken sourceTokenOfType:WCSourceTokenTypeHexadecimal range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner preProcessorRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypePreProcessor range:[result range] name:[[self string] substringWithRange:[result range]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		[[WCSourceScanner conditionalRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			
			[tokens addObject:[WCSourceToken sourceTokenOfType:WCSourceTokenTypeConditional range:[result rangeAtIndex:1] name:[[self string] substringWithRange:[result rangeAtIndex:1]]]];
		}];
		
		if ([self isCancelled])
			break;
		
		//NSSet *conditionalRegisters = [NSSet setWithObjects:@"nz",@"nv",@"nc",@"po",@"pe",@"c",@"p",@"m",@"n",@"z",@"v", nil];
		NSMutableSet *calledLabels = [NSMutableSet setWithCapacity:0];
		
		[[WCSourceScanner calledLabelRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			else if (![result rangeAtIndex:1].length)
				return;
			
			NSString *labelName = [[self string] substringWithRange:[result rangeAtIndex:1]];
			
			[calledLabels addObject:[labelName lowercaseString]];
		}];
		
		[[WCSourceScanner calledLabelWithConditionalRegularExpression] enumerateMatchesInString:[self string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if (NSLocationInRange([result range].location, [multilineCommentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [commentRanges rangeForRange:[result range]]) ||
				NSLocationInRange([result range].location, [stringRanges rangeForRange:[result range]]))
				return;
			else if (![result rangeAtIndex:1].length)
				return;
			
			NSString *labelName = [[self string] substringWithRange:[result rangeAtIndex:1]];
			
			[calledLabels addObject:[labelName lowercaseString]];
		}];
		
		if ([self isCancelled])
			break;
		
		[tokens sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
			if ([obj1 rangeValue].location < [obj2 rangeValue].location)
				return NSOrderedAscending;
			else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
				return NSOrderedDescending;
			return NSOrderedSame;
		}]]];
		
		[[self scanner] setTokens:tokens];
		[[self scanner] setCalledLabels:calledLabels];
		
		isFinished = YES;
	}
	
	[pool release];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceScannerDidFinishScanningNotification object:[self scanner]];
	});
}
#pragma mark *** Public Methods ***
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
#pragma mark Properties
@synthesize scanner=_scanner;
@synthesize string=_string;
@end
