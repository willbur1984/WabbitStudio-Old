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

NSString *const WCSourceHighlighterCommentColorAttributeName = @"commentColor";
NSString *const WCSourceHighlighterCommentFontAttributeName = @"commentFont";

@interface WCSourceHighlighter ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;

- (BOOL)_symbolName:(NSString *)symbolName existsInArrayOfSymbolNames:(NSArray *)arrayOfSymbolNames;
@end

@implementation WCSourceHighlighter
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_delegate = nil;
	_sourceScanner = nil;
	[super dealloc];
}

- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner; {
	if (!(self = [super init]))
		return nil;
	
	_needsToPerformFullHighlight = YES;
	_sourceScanner = sourceScanner;
	
	if ([sourceScanner needsToScanSymbols]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:sourceScanner];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanning:) name:WCSourceScannerDidFinishScanningNotification object:sourceScanner];
	}
	
	return self;
}

- (void)performHighlightingInVisibleRange; {
	for (NSLayoutManager *layoutManager in [[[self sourceScanner] textStorage] layoutManagers]) {
		for (NSTextContainer *textContainer in [layoutManager textContainers]) {
			if ([[textContainer textView] isHidden])
				continue;
			
			[self performHighlightingInRange:[[textContainer textView] visibleRange]];
		}
	}
}

- (void)performHighlightingInRange:(NSRange)range; {
	if (!range.length)
		return;
	else if (_needsToPerformFullHighlight) {
		_needsToPerformFullHighlight = NO;
		[self performHighlightingInRange:NSMakeRange(0, [[[self sourceScanner] textStorage] length])];
		return;
	}
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil] range:range];
	[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterCommentFontAttributeName range:range];
	[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterCommentColorAttributeName range:range];
	
	NSArray *labelNames = [[self delegate] labelSymbolsForSourceHighlighter:self];
	NSArray *equateNames = [[self delegate] equateSymbolsForSourceHighlighter:self];
	NSArray *defineNames = [[self delegate] defineSymbolsForSourceHighlighter:self];
	NSArray *macroNames = [[self delegate] macroSymbolsForSourceHighlighter:self];
	NSArray *tokens = [[self sourceScanner] tokens];
	
	[[WCSourceScanner symbolRegularExpression] enumerateMatchesInString:[[[self sourceScanner] textStorage] string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		WCSourceToken *token = [tokens sourceTokenForRange:[result range]];
		if (NSLocationInRange([result range].location, [token range]) &&
			([token type] == WCSourceTokenTypeComment || [token type] == WCSourceTokenTypeString))
			return;
		
		NSString *name = [[[[[self sourceScanner] textStorage] string] substringWithRange:[result range]] lowercaseString];
		
		if ([self _symbolName:name existsInArrayOfSymbolNames:equateNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateFont],NSFontAttributeName,[currentTheme equateColor],NSForegroundColorAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:labelNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelFont],NSFontAttributeName,[currentTheme labelColor],NSForegroundColorAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:macroNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroFont],NSFontAttributeName,[currentTheme macroColor],NSForegroundColorAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:defineNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineFont],NSFontAttributeName,[currentTheme defineColor],NSForegroundColorAttributeName, nil] range:[result range]];
		}
	}];
	
	for (WCSourceToken *token in [tokens sourceTokensForRange:range]) {
		switch ([token type]) {
			case WCSourceTokenTypeComment: {
				NSRange intersectRange = NSIntersectionRange([token range], range);
				if (intersectRange.length)
					[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterCommentColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterCommentFontAttributeName, nil] range:intersectRange];
			}
				break;
			case WCSourceTokenTypeBinary:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryFont],NSFontAttributeName,[currentTheme binaryColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeNumber:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberFont],NSFontAttributeName,[currentTheme numberColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeString:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringFont],NSFontAttributeName,[currentTheme stringColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeRegister:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerFont],NSFontAttributeName,[currentTheme registerColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeDirective:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveFont],NSFontAttributeName,[currentTheme directiveColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeMneumonic:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicFont],NSFontAttributeName,[currentTheme mneumonicColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeHexadecimal:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalFont],NSFontAttributeName,[currentTheme hexadecimalColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypePreProcessor:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorFont],NSFontAttributeName,[currentTheme preProcessorColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeConditional:
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalFont],NSFontAttributeName,[currentTheme conditionalColor],NSForegroundColorAttributeName, nil] range:[token range]];
				break;
			default:
				break;
		}
	}
	
	[[[self sourceScanner] textStorage] endEditing];
}

@synthesize sourceScanner=_sourceScanner;
@synthesize delegate=_delegate;

- (BOOL)_symbolName:(NSString *)symbolName existsInArrayOfSymbolNames:(NSArray *)arrayOfSymbolNames; {
	for (NSDictionary *symbolNames in arrayOfSymbolNames) {
		if ([symbolNames objectForKey:symbolName])
			return YES;
	}
	return NO;
}

- (void)_sourceScannerDidFinishScanning:(NSNotification *)note {
	[self performHighlightingInVisibleRange];
}

- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {
	[self performHighlightingInVisibleRange];
}
@end
