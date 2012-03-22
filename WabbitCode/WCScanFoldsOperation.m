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

@end

@implementation WCScanFoldsOperation
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		startMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:comment|macro|ifndef|ifdef|if)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
		endMarkersRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:endcomment|endmacro|endif)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
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
		
		if ([self isCancelled])
			break;
		
		// find all the start markers in our string
		[startMarkersRegex enumerateMatchesInString:[self string] options:0 range:NSMakeRange(0, [[self string] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
			NSString *name = [[[self string] substringWithRange:[result range]] lowercaseString];
			
			// if its a comment, add it
			if ([name isEqualToString:@"#comment"])
				[foldMarkers addObject:[WCFoldMarker foldMarkerOfType:WCFoldMarkerTypeCommentStart range:[result range]]];
			// otherwise check to see what the nearest token is to our match, if its a comment or string, dont add
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
		
		if ([self isCancelled])
			break;
		
		// find all the end markers in our string
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
		
		if ([self isCancelled])
			break;
		
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
		
		for (WCFoldMarker *foldMarker in foldMarkers) {
			switch ([foldMarker type]) {
					// we have a start marker, place it on our stack
				case WCFoldMarkerTypeCommentStart:
				case WCFoldMarkerTypeIfStart:
				case WCFoldMarkerTypeMacroStart:
					[foldMarkerStack addObject:foldMarker];
					break;
					// we have an end marker, now the fun begins!
				case WCFoldMarkerTypeCommentEnd:
				case WCFoldMarkerTypeIfEnd:
				case WCFoldMarkerTypeMacroEnd: {
					// grab the top element from our stack
					WCFoldMarker *startMarker = [foldMarkerStack lastObject];
					// our end marker is the current element
					WCFoldMarker *endMarker = foldMarker;
					
					// do the start and end types match?
					if (([startMarker type] == WCFoldMarkerTypeCommentStart && [endMarker type] == WCFoldMarkerTypeCommentEnd) ||
						([startMarker type] == WCFoldMarkerTypeIfStart && [endMarker type] == WCFoldMarkerTypeIfEnd) ||
						([startMarker type] == WCFoldMarkerTypeMacroStart && [endMarker type] == WCFoldMarkerTypeMacroEnd)) {
						
						// foldRange is the range that will be drawn in the code folding ribbon
						NSRange foldRange = [[self string] lineRangeForRange:NSUnionRange([startMarker range], [endMarker range])];
						// get the start index of the line after the start marker
						NSUInteger firstCharIndex = NSMaxRange([startMarker range]);
						// get the end index of the line before the end marker
						NSUInteger lastCharIndex = [endMarker range].location;
						// create our new fold, contentRange is everything that falls between the start index of the line after start marker the end index of the line before end marker
						NSRange contentRange = NSMakeRange(firstCharIndex, lastCharIndex-firstCharIndex);
						WCFoldType foldType;
						switch ([startMarker type]) {
							case WCFoldMarkerTypeCommentStart:
								foldType = WCFoldTypeComment;
								break;
							case WCFoldMarkerTypeIfStart:
								foldType = WCFoldTypeIf;
								break;
							case WCFoldMarkerTypeMacroStart:
								foldType = WCFoldTypeMacro;
								break;
							default:
								foldType = 0;
								break;
						}
						WCFold *newFold = [WCFold foldOfType:foldType level:0 range:foldRange contentRange:contentRange];
						
						[newFold setSourceScanner:[self sourceScanner]];
						
						// now look for possible children of our new fold, elements are encountered from deepest to top level so we get all child nodes before their parents, we have to look for the children now
						for (WCFold *childNode in [topLevelFolds reverseObjectEnumerator]) {
							// if the child range location in within our new folds foldRange, its our child
							if (NSLocationInRange([childNode range].location, [newFold range])) {
								[childNode retain];
								
								// increase the level, this will also increase the level of all the children of this node appropriately
								[childNode setLevel:[childNode level]+1];
								
								// remove the childNode from our list of top level nodes
								[topLevelFolds removeObjectIdenticalTo:childNode];
								// add the childNode to our newNode's children
								[[newFold mutableChildNodes] addObject:childNode];
								
								[childNode release];
							}
							else
								break;
						}
						
						// add the new node to our topLevelNodes array
						[topLevelFolds addObject:newFold];
						
						// remove the matched startMarker from our stack
						[foldMarkerStack removeLastObject];
					}
					else {
						// special case for when start and end markers aren't matched, search through our stack from the top down looking for a matching start marker
						for (WCFoldMarker *fold in [foldMarkerStack reverseObjectEnumerator]) {							
							startMarker = fold;
							
							// do the start and end types match?
							if (([startMarker type] == WCFoldMarkerTypeCommentStart && [endMarker type] == WCFoldMarkerTypeCommentEnd) ||
								([startMarker type] == WCFoldMarkerTypeIfStart && [endMarker type] == WCFoldMarkerTypeIfEnd) ||
								([startMarker type] == WCFoldMarkerTypeMacroStart && [endMarker type] == WCFoldMarkerTypeMacroEnd)) {
								
								NSRange foldRange = [[self string] lineRangeForRange:NSUnionRange([startMarker range], [endMarker range])];
								NSUInteger firstCharIndex = NSMaxRange([startMarker range]);
								NSUInteger lastCharIndex = [endMarker range].location;
								NSRange contentRange = NSMakeRange(firstCharIndex, lastCharIndex-firstCharIndex);
								WCFoldType foldType;
								switch ([startMarker type]) {
									case WCFoldMarkerTypeCommentStart:
										foldType = WCFoldTypeComment;
										break;
									case WCFoldMarkerTypeIfStart:
										foldType = WCFoldTypeIf;
										break;
									case WCFoldMarkerTypeMacroStart:
										foldType = WCFoldTypeMacro;
										break;
									default:
										foldType = 0;
										break;
								}
								WCFold *newFold = [WCFold foldOfType:foldType level:0 range:foldRange contentRange:contentRange];
								
								[newFold setSourceScanner:[self sourceScanner]];
								
								// search for child nodes of the new node, just as above
								for (WCFold *childNode in [topLevelFolds reverseObjectEnumerator]) {
									if (NSLocationInRange([childNode range].location, [newFold range])) {
										[childNode retain];
										
										[childNode setLevel:[childNode level]+1];
										
										[topLevelFolds removeObjectIdenticalTo:childNode];
										[[newFold mutableChildNodes] addObject:childNode];
										
										[childNode release];
									}
									else
										break;
								}
								
								[topLevelFolds addObject:newFold];
								
								// remove the matched startMarker from our stack
								[foldMarkerStack removeObjectIdenticalTo:startMarker];
								
								break;
							}
						}
					}
					
				}
					break;
				default:
					break;
			}
		}
		
		if ([self isCancelled])
			break;
		
		NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
			if ([obj1 rangeValue].location < [obj2 rangeValue].location)
				return NSOrderedAscending;
			else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
				return NSOrderedDescending;
			return NSOrderedSame;
		}]];
		
		// sort the top level folds by location
		[topLevelFolds sortUsingDescriptors:sortDescriptors];
		
		// sort all children of the top level folds (and their children, etc) using the same descriptors
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

@end
