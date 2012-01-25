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

@interface WCScanFoldsOperation ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) NSString *string;

- (void)_processFoldsForParentFold:(WCFold *)parentFold foldMarkers:(NSArray *)foldMarkers;
@end

@implementation WCScanFoldsOperation
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		startMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:macro|ifndef|ifdef|if)" options:NSRegularExpressionCaseInsensitive error:NULL];
		endMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:endmacro|endif)" options:NSRegularExpressionCaseInsensitive error:NULL];
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
	
	while (![self isCancelled] && !isFinished) {
		NSMutableArray *foldMarkers = [NSMutableArray arrayWithCapacity:0];
		
		[startMarkersRegex enumerateMatchesInString:[self string] options:0 range:NSMakeRange(0, [[self string] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if ([[[[self string] substringWithRange:[result range]] lowercaseString] isEqualToString:@"#macro"])
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeMacroStart range:[result range]]];
			else
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeIfStart range:[result range]]];
		}];
		
		[endMarkersRegex enumerateMatchesInString:[self string] options:0 range:NSMakeRange(0, [[self string] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			if ([[[[self string] substringWithRange:[result range]] lowercaseString] isEqualToString:@"#endmacro"])
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeMacroEnd range:[result range]]];
			else
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeIfEnd range:[result range]]];
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
					numberOfStartMarkers++;
					[foldMarkerStack addObject:foldMarker];
					
					if (numberOfStartMarkers == numberOfEndMarkers) {
						WCFoldMarker *startMarker = [foldMarkerStack lastObject];
						WCFoldMarker *endMarker = [foldMarkerStack firstObject];
						
						if (([startMarker type] == WCFoldMarkerTypeMacroStart && [endMarker type] == WCFoldMarkerTypeMacroEnd) ||
							([startMarker type] == WCFoldMarkerTypeIfStart && [endMarker type] == WCFoldMarkerTypeIfEnd)) {
							
							[topLevelFolds addObject:[WCFold foldWithRange:NSUnionRange([startMarker range], [endMarker range]) level:0]];
							
							[foldMarkerStack removeLastObject];
							[foldMarkerStack removeFirstObject];
							
							[self _processFoldsForParentFold:[topLevelFolds lastObject] foldMarkers:[[[[foldMarkerStack reverseObjectEnumerator] allObjects] copy] autorelease]];
							
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
					numberOfEndMarkers++;
					[foldMarkerStack addObject:foldMarker];
					break;
				default:
					break;
			}
		}];
		
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
				numberOfStartMarkers++;
				[foldMarkerStack addObject:foldMarker];
				
				if (numberOfStartMarkers == numberOfEndMarkers) {
					WCFoldMarker *startMarker = [foldMarkerStack lastObject];
					WCFoldMarker *endMarker = [foldMarkerStack firstObject];
					
					if (([startMarker type] == WCFoldMarkerTypeMacroStart && [endMarker type] == WCFoldMarkerTypeMacroEnd) ||
						([startMarker type] == WCFoldMarkerTypeIfStart && [endMarker type] == WCFoldMarkerTypeIfEnd)) {
						
						[[parentFold mutableChildNodes] addObject:[WCFold foldWithRange:NSUnionRange([startMarker range], [endMarker range]) level:[parentFold level]+1]];
						
						[foldMarkerStack removeLastObject];
						[foldMarkerStack removeFirstObject];
						
						[self _processFoldsForParentFold:[[parentFold childNodes] lastObject] foldMarkers:[[[[foldMarkerStack reverseObjectEnumerator] allObjects] copy] autorelease]];
						
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
				numberOfEndMarkers++;
				[foldMarkerStack addObject:foldMarker];
				break;
			default:
				break;
		}
	}];
}

@end