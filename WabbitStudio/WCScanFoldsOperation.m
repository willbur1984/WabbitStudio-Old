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
#import "WCFoldMarker.h"
#import "RSDefines.h"
#import "NSArray+WCExtensions.h"

static NSRegularExpression *startMarkersRegex;
static NSRegularExpression *endMarkersRegex;
static NSRegularExpression *regex;
static NSRegularExpression *childRegex;

@interface WCScanFoldsOperation ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) NSString *string;

- (void)_scanFoldsWithFold:(WCFold *)parentFold;
@end

@implementation WCScanFoldsOperation
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		startMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:macro|ifndef|ifdef|if)" options:NSRegularExpressionCaseInsensitive error:NULL];
		endMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:endmacro|endif)" options:NSRegularExpressionCaseInsensitive error:NULL];
		regex = [[NSRegularExpression alloc] initWithPattern:@"(?:#macro.*?#endmacro)|(?:(?:#ifndef|#ifdef|#if).*?#endif)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
		childRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:(?:#ifndef|#ifdef|#if).*?#endif)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
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
		
		[self _scanFoldsWithFold:[folds lastObject]];
	}];
	
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

- (void)_scanFoldsWithFold:(WCFold *)parentFold; {
	[childRegex enumerateMatchesInString:[self string] options:0 range:[parentFold range] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [result range];
		
		if (NSEqualRanges(range, [parentFold range])) {
			return;
		}
		
		for (WCFold *fold in [parentFold childNodes]) {
			if (NSLocationInRange(range.location, [fold range])) {
				return;
			}
		}
		
		[[parentFold mutableChildNodes] addObject:[WCFold foldWithRange:range level:[parentFold level]+1]];
		
		[self _scanFoldsWithFold:[[parentFold childNodes] lastObject]];
	}];
}

@end
