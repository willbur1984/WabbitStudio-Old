//
//  WCScanFoldsOperation.m
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCScanFoldsOperation.h"
#import "WCSourceScanner.h"
#import "WCFold.h"
#import "RSDefines.h"

static NSRegularExpression *regex;
static NSRegularExpression *childRegex;

@interface WCScanFoldsOperation ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) NSString *string;

- (void)_scanFoldsWithinFold:(WCFold *)fold;
@end

@implementation WCScanFoldsOperation
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		regex = [[NSRegularExpression alloc] initWithPattern:@"(?:#macro(.+?)#endmacro)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
		childRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:#if|#else)(.+?)(?:#else|#endif)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
	});
}

- (void)dealloc {
	[_sourceScanner release];
	[_string release];
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([self isCancelled])
		goto CLEANUP;
	
	NSMutableArray *folds = [NSMutableArray arrayWithCapacity:0];
	
	[regex enumerateMatchesInString:[self string] options:0 range:NSMakeRange(0, [[self string] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [result range];
		
		for (WCFold *fold in folds) {
			if (NSLocationInRange(range.location, [fold range]))
				return;
		}
		
		[folds addObject:[WCFold foldWithRange:range level:0]];
		
		[self _scanFoldsWithinFold:[folds lastObject]];
	}];
	
	for (WCFold *fold in folds)
		[self _scanFoldsWithinFold:fold];
	
	[[self sourceScanner] setFolds:folds];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceScannerDidFinishScanningFoldsNotification object:[self sourceScanner]];
	});
	
CLEANUP:
	[pool release];
}

+ (WCScanFoldsOperation *)scanFoldsOperationWithSourceScanner:(WCSourceScanner *)sourceScanner; {
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

- (void)_scanFoldsWithinFold:(WCFold *)fold; {
	[childRegex enumerateMatchesInString:[self string] options:0 range:[fold range] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [result rangeAtIndex:1];
		
		if (NSEqualRanges(range, [fold range]))
			return;
		
		[[fold mutableChildNodes] addObject:[WCFold foldWithRange:range level:[fold level]+1]];
		
		[self _scanFoldsWithinFold:[[fold childNodes] lastObject]];
	}];
}

@end
