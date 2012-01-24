//
//  WCSourceHighlighter.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceHighlighter.h"
#import "WCSourceScanner.h"
#import "WCSourceToken.h"
#import "NSTextView+WCExtensions.h"
#import "WCSourceSymbol.h"
#import "NSArray+WCExtensions.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "RSDefines.h"

@interface WCSourceHighlighter ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;

- (BOOL)_symbolName:(NSString *)symbolName existsInArrayOfSymbolNames:(NSArray *)arrayOfSymbolNames;
@end

@implementation WCSourceHighlighter
#pragma mark *** Subclass Overrides ***

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_delegate = nil;
	_sourceScanner = nil;
	[super dealloc];
}
#pragma mark *** Public Methods ***
- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner; {
	if (!(self = [super init]))
		return nil;
	
	//_needsToPerformFullHighlight = YES;
	_sourceScanner = sourceScanner;
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageWillProcessEditing:) name:NSTextStorageWillProcessEditingNotification object:[sourceScanner textStorage]];
	
	if ([sourceScanner needsToScanSymbols]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:sourceScanner];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanning:) name:WCSourceScannerDidFinishScanningNotification object:sourceScanner];
	}
	
	return self;
}

- (void)performHighlightingInVisibleRange; {
	NSMutableIndexSet *ranges = [NSMutableIndexSet indexSet];
	for (NSLayoutManager *layoutManager in [[[self sourceScanner] textStorage] layoutManagers]) {
		for (NSTextContainer *textContainer in [layoutManager textContainers]) {
			[ranges addIndexesInRange:[[textContainer textView] visibleRange]];
		}
	}
	[ranges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
		[self performHighlightingInRange:range];
	}];
}

- (void)performHighlightingInRange:(NSRange)range; {
	if (![[[self sourceScanner] textStorage] length])
		return;
	
	//NSLogRange(range);
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil] range:range];
	
	NSArray *labelNames = [[self delegate] labelSymbolsForSourceHighlighter:self];
	NSArray *equateNames = [[self delegate] equateSymbolsForSourceHighlighter:self];	
	NSArray *defineNames = [[self delegate] defineSymbolsForSourceHighlighter:self];
	NSArray *macroNames = [[self delegate] macroSymbolsForSourceHighlighter:self];
	NSArray *tokens = [[self sourceScanner] tokens];
	
	[[WCSourceScanner symbolRegularExpression] enumerateMatchesInString:[[[self sourceScanner] textStorage] string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		WCSourceToken *token = [tokens sourceTokenForRange:[result range]];
		if (token && NSLocationInRange([result range].location, [token range]))
			return;
		
		NSString *name = [[[[[self sourceScanner] textStorage] string] substringWithRange:[result range]] lowercaseString];
		
		if ([self _symbolName:name existsInArrayOfSymbolNames:equateNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateFont],NSFontAttributeName,[currentTheme equateColor],NSForegroundColorAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:labelNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelFont],NSFontAttributeName,[currentTheme labelColor],NSForegroundColorAttributeName,nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:macroNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroFont],NSFontAttributeName,[currentTheme macroColor],NSForegroundColorAttributeName,nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:defineNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineFont],NSFontAttributeName,[currentTheme defineColor],NSForegroundColorAttributeName,nil] range:[result range]];
		}
	}];
	
	for (WCSourceToken *token in [tokens sourceTokensForRange:range]) {
		switch ([token type]) {
				// special case for multiline comments that can extend past our visible range
			case WCSourceTokenTypeComment: {
				NSRange intersectRange = NSIntersectionRange([token range], range);
				if (intersectRange.length)
					[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName,nil] range:intersectRange];
			}
				break;
			case WCSourceTokenTypeBinary:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryFont],NSFontAttributeName,[currentTheme binaryColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeNumber:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberFont],NSFontAttributeName,[currentTheme numberColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeString:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringFont],NSFontAttributeName,[currentTheme stringColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeRegister:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerFont],NSFontAttributeName,[currentTheme registerColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeDirective:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveFont],NSFontAttributeName,[currentTheme directiveColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeMneumonic:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicFont],NSFontAttributeName,[currentTheme mneumonicColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeHexadecimal:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalFont],NSFontAttributeName,[currentTheme hexadecimalColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypePreProcessor:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorFont],NSFontAttributeName,[currentTheme preProcessorColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			case WCSourceTokenTypeConditional:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalFont],NSFontAttributeName,[currentTheme conditionalColor],NSForegroundColorAttributeName,nil] range:[token range]];
				break;
			default:
				break;
		}
	}
	
	[[[self sourceScanner] textStorage] endEditing];
}

- (void)highlightAttributeString:(NSMutableAttributedString *)attributedString; {
	[self highlightAttributeString:attributedString withArgumentNames:nil];
}
- (void)highlightAttributeString:(NSMutableAttributedString *)attributedString withArgumentNames:(NSSet *)argumentNames; {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	NSArray *labelNames = [[self delegate] labelSymbolsForSourceHighlighter:self];
	NSArray *equateNames = [[self delegate] equateSymbolsForSourceHighlighter:self];
	NSArray *defineNames = [[self delegate] defineSymbolsForSourceHighlighter:self];
	NSArray *macroNames = [[self delegate] macroSymbolsForSourceHighlighter:self];
	NSRange range = NSMakeRange(0, [attributedString length]);
	
	[[WCSourceScanner symbolRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {		
		NSString *name = [[[attributedString string] substringWithRange:[result range]] lowercaseString];
		
		if ([self _symbolName:name existsInArrayOfSymbolNames:equateNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateColor],NSForegroundColorAttributeName,nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:labelNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelColor],NSForegroundColorAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:macroNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroColor],NSForegroundColorAttributeName,nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:defineNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineColor],NSForegroundColorAttributeName,nil] range:[result range]];
		}
		
		if ([argumentNames containsObject:name])
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner mnemonicRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *name = [[attributedString string] substringWithRange:[result range]];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicColor],NSForegroundColorAttributeName, nil] range:[result range]];
		
		if ([argumentNames containsObject:name])
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner registerRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *name = [[attributedString string] substringWithRange:[result range]];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerColor],NSForegroundColorAttributeName, nil] range:[result range]];
		
		if ([argumentNames containsObject:name])
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner preProcessorRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner directiveRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *name = [[attributedString string] substringWithRange:[result range]];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveColor],NSForegroundColorAttributeName, nil] range:[result range]];
		
		if ([argumentNames containsObject:name])
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner hexadecimalRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner numberRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner binaryRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner stringRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner conditionalRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *name = [[attributedString string] substringWithRange:[result range]];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalColor],NSForegroundColorAttributeName, nil] range:[result rangeAtIndex:1]];
		
		if ([argumentNames containsObject:name])
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
}
#pragma mark Properties
@synthesize sourceScanner=_sourceScanner;
@synthesize delegate=_delegate;
#pragma mark *** Private Methods ***
- (BOOL)_symbolName:(NSString *)symbolName existsInArrayOfSymbolNames:(NSArray *)arrayOfSymbolNames; {
	for (NSDictionary *symbolNames in arrayOfSymbolNames) {
		if ([symbolNames objectForKey:symbolName])
			return YES;
	}
	return NO;
}
#pragma mark Notifications

- (void)_sourceScannerDidFinishScanning:(NSNotification *)note {
	//[self performHighlightingInVisibleRange];
}

- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {
	//[self performFullHighlightIfNeeded];
	[self performHighlightingInVisibleRange];
}
@end
