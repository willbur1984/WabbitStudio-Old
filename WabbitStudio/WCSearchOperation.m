//
//  WCSearchOperation.m
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
	NSMapTable *sourceFileDocumentsToSearchContainers = [[NSMapTable mapTableWithWeakToStrongObjects] retain];
	__block NSUInteger numberOfSearchResults = 0;
	
	while (![self isCancelled] && !isFinished) {
		for (WCSourceFileDocument *sfDocument in [self searchDocuments]) {
			if ([self isCancelled])
				break;
			
			NSString *string = [[[[sfDocument textStorage] string] copy] autorelease];
			NSUInteger stringLength = [string length];
			NSArray *tokens = [[sfDocument sourceScanner] tokens];
			NSArray *symbols = [[sfDocument sourceScanner] symbols];
			
			CFLocaleRef currentLocale = CFLocaleCopyCurrent();
			CFStringTokenizerRef stringTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef)string, CFRangeMake(0, (CFIndex)stringLength), kCFStringTokenizerUnitWordBoundary, currentLocale);
			CFRelease(currentLocale);
			
			// textual matching
			if ([self findStyle] == RSFindOptionsFindStyleTextual) {
				NSRange searchRange = NSMakeRange(0, stringLength);
				NSStringCompareOptions options = ([self matchCase])?NSLiteralSearch:(NSLiteralSearch|NSCaseInsensitiveSearch);
				
				while (searchRange.location < stringLength) {
					NSRange foundRange = [string rangeOfString:[self searchString] options:options range:searchRange];
					if (foundRange.location == NSNotFound)
						break;
					
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
							
							dispatch_async(dispatch_get_main_queue(), ^{
								[[NSNotificationCenter defaultCenter] addObserver:[self searchNavigatorViewController] selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[sfDocument textStorage]];
							});
						}
						
						[[parentContainer mutableChildNodes] addObject:[WCSearchResultContainer searchResultContainerWithSearchResult:searchResult]];
						numberOfSearchResults++;
					}
					
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
			[[self searchNavigatorViewController] setStatusString:[NSString stringWithFormat:NSLocalizedString(@"%lu result(s) in %lu file(s)", @"search navigator status format string"),numberOfSearchResults,[[self searchDocuments] count]]];
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
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:[string substringWithRange:firstLineRange] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]],NSFontAttributeName, nil]] autorelease];
	
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
