//
//  WCSearchOperation.m
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSearchOperation.h"
#import "WCSearchNavigatorViewController.h"
#import "WCSourceFileDocument.h"
#import "WCSourceTextStorage.h"
#import "WCProjectDocument.h"
#import "WCSourceScanner.h"
#import "WCSourceToken.h"
#import "WCSourceSymbol.h"
#import "WCSearchContainer.h"
#import "WCSearchResultContainer.h"
#import "WCSearchResult.h"
#import "WCDefines.h"
#import "NSParagraphStyle+RSExtensions.h"
#import "NSArray+WCExtensions.h"

@interface WCSearchOperation ()
@property (readonly,nonatomic) WCSearchNavigatorViewController *searchNavigatorViewController;
@property (readonly,nonatomic) NSString *searchString;
@property (readonly,nonatomic) NSArray *searchDocuments;
@property (readonly,nonatomic) RSFindOptionsFindStyle findStyle;
@property (readonly,nonatomic) RSFindOptionsMatchStyle matchStyle;
@property (readonly,nonatomic) BOOL matchCase;
@property (readonly,nonatomic) NSRegularExpression *searchRegularExpression;

- (WCSearchResult *)_searchResultForRange:(NSRange)range string:(NSString *)string tokens:(NSArray *)tokens symbols:(NSArray *)symbols;
@end

@implementation WCSearchOperation
- (void)dealloc {
	[_searchRegularExpression release];
	[_searchNavigatorViewController release];
	[_searchString release];
	[_searchDocuments release];
	[super dealloc];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL isFinished = NO;
	
	NSMutableArray *searchResults = [NSMutableArray arrayWithCapacity:[[self searchDocuments] count]];
	NSMapTable *sourceFileDocumentsToSearchContainers = [NSMapTable mapTableWithWeakToStrongObjects];
	__block NSUInteger numberOfSearchResults = 0;
	
	while (![self isCancelled] && !isFinished) {
		for (WCSourceFileDocument *sfDocument in [self searchDocuments]) {
			if ([self isCancelled])
				break;
			
			// grab a copy of the source file document's string
			NSString *string = [[[[sfDocument textStorage] string] copy] autorelease];
			NSUInteger stringLength = [string length];
			NSArray *tokens = [[sfDocument sourceScanner] tokens];
			NSArray *symbols = [[sfDocument sourceScanner] symbols];
			
			// grab a copy of the current locale
			CFLocaleRef currentLocale = CFLocaleCopyCurrent();
			// create a string tokenizer to determine the word boundaries in the string, this is needed for a number of search options
			CFStringTokenizerRef stringTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef)string, CFRangeMake(0, (CFIndex)stringLength), kCFStringTokenizerUnitWordBoundary, currentLocale);
			// release the copy of the current locale we were given above
			CFRelease(currentLocale);
			
			// textual matching
			if ([self findStyle] == RSFindOptionsFindStyleTextual) {
				// search range is initially the entire string length
				NSRange searchRange = NSMakeRange(0, stringLength);
				// if our match case option is turned on OR in the appropriate flag
				NSStringCompareOptions options = ([self matchCase])?NSLiteralSearch:(NSLiteralSearch|NSCaseInsensitiveSearch);
				
				// while our current location in the string is less than the string length, continue searching
				while (searchRange.location < stringLength) {
					// search for the search string within the search range given the options above
					NSRange foundRange = [string rangeOfString:[self searchString] options:options range:searchRange];
					// if nothing was found, bail early
					if (foundRange.location == NSNotFound)
						break;
					
					// tell the string tokenizer to jump to the nearest token for the found range
					CFStringTokenizerGoToTokenAtIndex(stringTokenizer, (CFIndex)foundRange.location);
					// grab the token range (i.e. full word range) corresponding to the found range
					CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(stringTokenizer);
					
					WCSearchResult *searchResult = nil;
					
					// depending on our match style, we may have found a match
					switch ([self matchStyle]) {
						case RSFindOptionsMatchStyleContains:
							searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
							// token range and found range starting indexes must match and match range can't be longer than token range
						case RSFindOptionsMatchStyleStartsWith:
							if (foundRange.location == tokenRange.location &&
								foundRange.length < tokenRange.length)
								searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
							// the ending indexes of token range and found range must match
						case RSFindOptionsMatchStyleEndsWith:
							if (NSMaxRange(foundRange) == (tokenRange.location + tokenRange.length))
								searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
							// token range and found range must match exactly
						case RSFindOptionsMatchStyleWholeWord:
							if (foundRange.location == tokenRange.location &&
								foundRange.length == tokenRange.length)
								searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
						default:
							break;
					}
					
					if (searchResult) {
						// if we found a match, see if the parent container for matches in that file already exists
						WCSearchContainer *parentContainer = [sourceFileDocumentsToSearchContainers objectForKey:sfDocument];
						
						if (!parentContainer) {
							// if the parent container doesn't exist (i.e. this is the first match we found in the current file), create it
							parentContainer = [WCSearchContainer searchContainerWithFile:[[[sfDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sfDocument]];
							
							// add the parent container to our top level array
							[searchResults addObject:parentContainer];
							// add the parent container to the map table so we can retrieve it quickly for subsequent matches
							[sourceFileDocumentsToSearchContainers setObject:parentContainer forKey:sfDocument];
							
							dispatch_async(dispatch_get_main_queue(), ^{
								// add the search navigator view controller as an observer for the NSTextStorageDidProcessEditingNotification
								// this has to be done on the main thread, which ensures the resulting notifications are also delievered
								// on the main thread
								[[NSNotificationCenter defaultCenter] addObserver:[self searchNavigatorViewController] selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[sfDocument textStorage]];
							});
						}
						
						// add a new search result container to the parent container
						[[parentContainer mutableChildNodes] addObject:[WCSearchResultContainer searchResultContainerWithSearchResult:searchResult]];
						// increase our counter for the number of search results
						numberOfSearchResults++;
					}
					
					// adjust our search and continue
					searchRange = NSMakeRange(NSMaxRange(foundRange), stringLength-NSMaxRange(foundRange));
					
				}
			}
			// regular expression matching
			else {
				[[self searchRegularExpression] enumerateMatchesInString:string options:0 range:NSMakeRange(0, stringLength) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
					NSRange foundRange = [result range];
					CFStringTokenizerGoToTokenAtIndex(stringTokenizer, (CFIndex)foundRange.location);
					CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(stringTokenizer);
					
					WCSearchResult *searchResult = nil;
					
					switch ([self matchStyle]) {
						case RSFindOptionsMatchStyleContains:
							searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
							// token range and found range starting indexes must match and match range can't be longer than token range
						case RSFindOptionsMatchStyleStartsWith:
							if (foundRange.location == tokenRange.location &&
								foundRange.length < tokenRange.length)
								searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
							// the ending indexes of token range and found range must match
						case RSFindOptionsMatchStyleEndsWith:
							if (NSMaxRange(foundRange) == (tokenRange.location + tokenRange.length))
								searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
							// token range and found range must match exactly
						case RSFindOptionsMatchStyleWholeWord:
							if (foundRange.location == tokenRange.location &&
								foundRange.length == tokenRange.length)
								searchResult = [self _searchResultForRange:foundRange string:string tokens:tokens symbols:symbols];
							break;
						default:
							break;
					}
					
					if (searchResult) {
						WCSearchContainer *parentContainer = [sourceFileDocumentsToSearchContainers objectForKey:sfDocument];
						
						if (!parentContainer) {
							parentContainer = [WCSearchContainer searchContainerWithFile:[[[sfDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sfDocument]];
							
							[searchResults addObject:parentContainer];
							[sourceFileDocumentsToSearchContainers setObject:parentContainer forKey:sfDocument];
						}
						
						[[parentContainer mutableChildNodes] addObject:[WCSearchResultContainer searchResultContainerWithSearchResult:searchResult]];
						numberOfSearchResults++;
					}
				}];
			}
			
			CFRelease(stringTokenizer);
		}
		
		[searchResults sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"representedObject.fileName" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
		
		isFinished = YES;
	}
	
	if ([self isCancelled]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self searchNavigatorViewController] setStatusString:NSLocalizedString(@"Search cancelled", @"Search cancelled")];
			[[self searchNavigatorViewController] setSearching:NO];
			
			[[NSNotificationCenter defaultCenter] removeObserver:[self searchNavigatorViewController] name:NSTextStorageDidProcessEditingNotification object:nil];
		});
	}
	else {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *resultsString;
			if (numberOfSearchResults == 1)
				resultsString = NSLocalizedString(@"1 result", @"1 result");
			else
				resultsString = [NSString stringWithFormat:NSLocalizedString(@"%lu results", @"%lu results"),numberOfSearchResults];
			
			NSString *documentsString;
			if ([[self searchDocuments] count] == 1)
				documentsString = NSLocalizedString(@"1 file", @"1 file");
			else
				documentsString = [NSString stringWithFormat:NSLocalizedString(@"%lu files", @"%lu files"),[[self searchDocuments] count]];
			
			[[self searchNavigatorViewController] setStatusString:[NSString stringWithFormat:NSLocalizedString(@"%@ in %@", @"search navigator status format string"),resultsString,documentsString]];
			[[self searchNavigatorViewController] setSearching:NO];
			
			[[[self searchNavigatorViewController] searchContainer] willChangeValueForKey:@"searchStatus"];
			[[[[self searchNavigatorViewController] searchContainer] mutableChildNodes] addObjectsFromArray:searchResults];
			[[[self searchNavigatorViewController] searchContainer] didChangeValueForKey:@"searchStatus"];
			
			[[[self searchNavigatorViewController] outlineView] expandItem:nil expandChildren:YES];
		});
	}
	
	[pool release];
}

- (id)initWithSearchNavigatorViewController:(WCSearchNavigatorViewController *)searchNavigatorViewController; {
	if (!(self = [super init]))
		return nil;
	
	_searchNavigatorViewController = [searchNavigatorViewController retain];
	_searchString = [[searchNavigatorViewController searchString] copy];
	
	switch ([searchNavigatorViewController searchScope]) {
		case WCSearchNavigatorSearchScopeAllFiles:
			_searchDocuments = [[[searchNavigatorViewController projectDocument] sourceFileDocuments] copy];
			break;
		case WCSearchNavigatorSearchScopeOpenFiles:
			_searchDocuments = [[[searchNavigatorViewController projectDocument] openSourceFileDocuments] copy];
			break;
		case WCSearchNavigatorSearchScopeSelectedFiles:
			_searchDocuments = nil;
			break;
		default:
			break;
	}
	
	_findStyle = [[searchNavigatorViewController searchOptionsViewController] findStyle];
	_matchStyle = [[searchNavigatorViewController searchOptionsViewController] matchStyle];
	_matchCase = [[searchNavigatorViewController searchOptionsViewController] matchCase];
	_searchRegularExpression = [[searchNavigatorViewController searchRegularExpression] retain];
	
	return self;
}

@synthesize searchNavigatorViewController=_searchNavigatorViewController;
@synthesize searchString=_searchString;
@synthesize searchDocuments=_searchDocuments;
@synthesize findStyle=_findStyle;
@synthesize matchCase=_matchCase;
@synthesize matchStyle=_matchStyle;
@synthesize searchRegularExpression=_searchRegularExpression;

- (WCSearchResult *)_searchResultForRange:(NSRange)range string:(NSString *)string tokens:(NSArray *)tokens symbols:(NSArray *)symbols; {
	NSRange lineRange = [string lineRangeForRange:range];
	NSRange firstLineRange = [string lineRangeForRange:NSMakeRange(range.location, 0)];
	NSString *lineString = [string substringWithRange:lineRange];
	// replace all tabs with spaces, so the line is smaller and more likely to fit in the search navigator outline view
	NSString *firstLineString = [[string substringWithRange:firstLineRange] stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:firstLineString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]],NSFontAttributeName, nil]] autorelease];
	
	if (NSMaxRange(range) > NSMaxRange(firstLineRange))
		[attributedString addAttributes:WCTransparentFindTextAttributes() range:NSMakeRange(0, [attributedString length])];
	else {
		[attributedString addAttributes:WCTransparentFindTextAttributes() range:NSMakeRange(range.location-firstLineRange.location, range.length)];
		
		NSUInteger midCharIndex = (NSUInteger)floor(firstLineRange.length/2.0);
		
		if (range.location-firstLineRange.location > midCharIndex)
			[attributedString addAttribute:NSParagraphStyleAttributeName value:[NSParagraphStyle truncatingHeadParagraphStyle] range:NSMakeRange(0, [attributedString length])];
		else
			[attributedString addAttribute:NSParagraphStyleAttributeName value:[NSParagraphStyle truncatingTailParagraphStyle] range:NSMakeRange(0, [attributedString length])];
	}
	
	lineString = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	id tokenOrSymbol = [symbols sourceSymbolForRange:range];
	if (tokenOrSymbol && NSLocationInRange(range.location, [tokenOrSymbol range])) {
		[attributedString applyFontTraits:NSBoldFontMask range:NSMakeRange([tokenOrSymbol range].location-firstLineRange.location, [tokenOrSymbol range].length)];
		
		return [WCSearchResult searchResultWithRange:range string:lineString attributedString:attributedString tokenOrSymbol:tokenOrSymbol];
	}
	
	tokenOrSymbol = [tokens sourceTokenForRange:range];
	if (tokenOrSymbol && NSLocationInRange(range.location, [tokenOrSymbol range]))
		return [WCSearchResult searchResultWithRange:range string:lineString attributedString:attributedString tokenOrSymbol:tokenOrSymbol];
	
	return [WCSearchResult searchResultWithRange:range string:lineString attributedString:attributedString tokenOrSymbol:nil];
}

@end
