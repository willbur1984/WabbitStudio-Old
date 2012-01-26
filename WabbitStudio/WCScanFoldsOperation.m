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
#import "WCSourceToken.h"

static NSRegularExpression *startMarkersRegex;
static NSRegularExpression *endMarkersRegex;

@interface WCScanFoldsOperation ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) NSString *string;

- (void)_processFoldsForParentFold:(WCFold *)parentFold foldMarkers:(NSArray *)foldMarkers;
@end

@implementation WCScanFoldsOperation
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		startMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:comment|macro|ifndef|ifdef|if)" options:NSRegularExpressionCaseInsensitive error:NULL];
		endMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:endcomment|endmacro|endif)" options:NSRegularExpressionCaseInsensitive error:NULL];
	});
}

- (void)dealloc {
	[_sourceScanner release];
	[_string release];
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL isFinished = NO;
	NSArray *tokens = [[self sourceScanner] tokens];
	
	while (![self isCancelled] && !isFinished) {
		NSMutableArray *foldMarkers = [NSMutableArray arrayWithCapacity:0];
		
		[startMarkersRegex enumerateMatchesInString:[self string] options:0 range:NSMakeRange(0, [[self string] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSString *name = [[[self string] substringWithRange:[result range]] lowercaseString];
			
			if ([name isEqualToString:@"#comment"])
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeCommentStart range:[result range]]];
			else {
				WCSourceToken *token = [tokens sourceTokenForRange:[result range]];
				if (([token type] == WCSourceTokenTypeComment ||
					 [token type] == WCSourceTokenTypeString) &&
					NSLocationInRange([result range].location, [token range]))
					return;
				
				if ([name isEqualToString:@"#macro"])
					[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeMacroStart range:[result range]]];
				else
					[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeIfStart range:[result range]]];
			}
		}];
		
		[endMarkersRegex enumerateMatchesInString:[self string] options:0 range:NSMakeRange(0, [[self string] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSString *name = [[[self string] substringWithRange:[result range]] lowercaseString];
			
			if ([name isEqualToString:@"#endcomment"])
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeCommentEnd range:[result range]]];
			else {
				WCSourceToken *token = [tokens sourceTokenForRange:[result range]];
				if (([token type] == WCSourceTokenTypeComment ||
					 [token type] == WCSourceTokenTypeString) &&
					NSLocationInRange([result range].location, [token range]))
					return;
				
				if ([name isEqualToString:@"#endmacro"])
					[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeMacroEnd range:[result range]]];
				else
					[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeIfEnd range:[result range]]];
			}
		}];
		
		[foldMarkers sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
			if ([obj1 rangeValue].location < [obj2 rangeValue].location)
				return NSOrderedAscending;
			else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
				return NSOrderedDescending;
			return NSOrderedSame;
		}]]];
		
		if ([self isCancelled])
			break;
		
		NSMutableArray *topLevelFolds = [NSMutableArray arrayWithCapacity:0];
		NSMutableArray *foldMarkerStack = [NSMutableArray arrayWithCapacity:0];
		__block NSUInteger numberOfStartMarkers = 0;
		__block NSUInteger numberOfEndMarkers = 0;
		
		[foldMarkers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(WCFoldMarker *foldMarker, NSUInteger foldMarkerIndex, BOOL *stop) {
			switch ([foldMarker type]) {
				case WCFoldMarkerTypeMacroStart:
				case WCFoldMarkerTypeIfStart:
				case WCFoldMarkerTypeCommentStart:
					numberOfStartMarkers++;
					[foldMarkerStack addObject:foldMarker];
					
					if (numberOfStartMarkers == numberOfEndMarkers) {
						WCFoldMarker *startMarker = [foldMarkerStack lastObject];
						WCFoldMarker *endMarker = [foldMarkerStack firstObject];
						
						if (([startMarker type] == WCFoldMarkerTypeMacroStart && [endMarker type] == WCFoldMarkerTypeMacroEnd) ||
							([startMarker type] == WCFoldMarkerTypeIfStart && [endMarker type] == WCFoldMarkerTypeIfEnd) ||
							([startMarker type] == WCFoldMarkerTypeCommentStart && [endMarker type] == WCFoldMarkerTypeCommentEnd)) {
							
							NSRange foldRange = NSUnionRange([startMarker range], [endMarker range]);
							foldRange = [[self string] lineRangeForRange:foldRange];
							
							[topLevelFolds addObject:[WCFold foldWithRange:foldRange level:0 contentRange:NSEmptyRange]];
							
							[foldMarkerStack removeLastObject];
							[foldMarkerStack removeFirstObject];
							
							[self _processFoldsForParentFold:[topLevelFolds lastObject] foldMarkers:[[foldMarkerStack reverseObjectEnumerator] allObjects]];
							
							numberOfEndMarkers = 0;
							numberOfStartMarkers = 0;
							[foldMarkerStack removeAllObjects];
						}
					}
					else if (numberOfStartMarkers > numberOfEndMarkers) {
						numberOfEndMarkers = 0;
						numberOfStartMarkers = 0;
						[foldMarkerStack removeAllObjects];
					}
					break;
				case WCFoldMarkerTypeMacroEnd:
				case WCFoldMarkerTypeIfEnd:
				case WCFoldMarkerTypeCommentEnd:
					numberOfEndMarkers++;
					[foldMarkerStack addObject:foldMarker];
					break;
				default:
					break;
			}
		}];
		
		NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
			if ([obj1 rangeValue].location < [obj2 rangeValue].location)
				return NSOrderedAscending;
			else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
				return NSOrderedDescending;
			return NSOrderedSame;
		}]];
		
		[topLevelFolds sortUsingDescriptors:sortDescriptors];
		
		for (WCFold *fold in topLevelFolds)
			[fold sortWithSortDescriptors:sortDescriptors recursively:YES];
		
		if ([self isCancelled])
			break;
		
		[[self sourceScanner] setFolds:topLevelFolds];
		
		isFinished = YES;
	}
	
	[pool release];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceScannerDidFinishScanningFoldsNotification object:[self sourceScanner]];
	});
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

- (void)_processFoldsForParentFold:(WCFold *)parentFold foldMarkers:(NSArray *)foldMarkers; {
	NSMutableArray *foldMarkerStack = [NSMutableArray arrayWithCapacity:0];
	__block NSUInteger numberOfStartMarkers = 0;
	__block NSUInteger numberOfEndMarkers = 0;
	
	[foldMarkers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(WCFoldMarker *foldMarker, NSUInteger foldMarkerIndex, BOOL *stop) {
		switch ([foldMarker type]) {
			case WCFoldMarkerTypeMacroStart:
			case WCFoldMarkerTypeIfStart:
			case WCFoldMarkerTypeCommentStart:
				numberOfStartMarkers++;
				[foldMarkerStack addObject:foldMarker];
				
				if (numberOfStartMarkers == numberOfEndMarkers) {
					WCFoldMarker *startMarker = [foldMarkerStack lastObject];
					WCFoldMarker *endMarker = [foldMarkerStack firstObject];
					
					if (([startMarker type] == WCFoldMarkerTypeMacroStart && [endMarker type] == WCFoldMarkerTypeMacroEnd) ||
						([startMarker type] == WCFoldMarkerTypeIfStart && [endMarker type] == WCFoldMarkerTypeIfEnd) ||
						([startMarker type] == WCFoldMarkerTypeCommentStart && [endMarker type] == WCFoldMarkerTypeCommentEnd)) {
						
						NSRange foldRange = NSUnionRange([startMarker range], [endMarker range]);
						foldRange = [[self string] lineRangeForRange:foldRange];
						
						[[parentFold mutableChildNodes] addObject:[WCFold foldWithRange:foldRange level:[parentFold level]+1 contentRange:NSEmptyRange]];
						
						[foldMarkerStack removeLastObject];
						[foldMarkerStack removeFirstObject];
						
						[self _processFoldsForParentFold:[[parentFold childNodes] lastObject] foldMarkers:[[foldMarkerStack reverseObjectEnumerator] allObjects]];
						
						numberOfEndMarkers = 0;
						numberOfStartMarkers = 0;
						[foldMarkerStack removeAllObjects];
					}
				}
				else if (numberOfStartMarkers > numberOfEndMarkers) {
					numberOfEndMarkers = 0;
					numberOfStartMarkers = 0;
					[foldMarkerStack removeAllObjects];
				}
				break;
			case WCFoldMarkerTypeMacroEnd:
			case WCFoldMarkerTypeIfEnd:
			case WCFoldMarkerTypeCommentEnd:
				numberOfEndMarkers++;
				[foldMarkerStack addObject:foldMarker];
				break;
			default:
				break;
		}
	}];
}

@end
