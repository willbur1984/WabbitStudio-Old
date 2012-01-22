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

NSString *const WCSourceHighlighterPlainTextAttributeName = @"plainTextAttributeName";
NSString *const WCSourceHighlighterCommentAttributeName = @"commentAttributeName";
NSString *const WCSourceHighlighterBinaryAttributeName = @"binaryAttributeName";
NSString *const WCSourceHighlighterNumberAttributeName = @"numberAttributeName";
NSString *const WCSourceHighlighterStringAttributeName = @"stringAttributeName";
NSString *const WCSourceHighlighterRegisterAttributeName = @"registerAttributeName";
NSString *const WCSourceHighlighterDirectiveAttributeName = @"directiveAttributeName";
NSString *const WCSourceHighlighterMneumonicAttributeName = @"mneumonicAttributeName";
NSString *const WCSourceHighlighterHexadecimalAttributeName = @"hexadecimalAttributeName";
NSString *const WCSourceHighlighterPreProcessorAttributeName = @"preProcessorAttributeName";
NSString *const WCSourceHighlighterConditionalAttributeName = @"conditionalAttributeName";
NSString *const WCSourceHighlighterLabelAttributeName = @"labelAttributeName";
NSString *const WCSourceHighlighterEquateAttributeName = @"equateAttributeName";
NSString *const WCSourceHighlighterDefineAttributeName = @"defineAttributeName";
NSString *const WCSourceHighlighterMacroAttributeName = @"macroAttributeName";

static NSDictionary *attributeNamesToColorSelectors;
static NSDictionary *attributeNamesToFontSelectors;

@interface WCSourceHighlighter ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;

- (BOOL)_symbolName:(NSString *)symbolName existsInArrayOfSymbolNames:(NSArray *)arrayOfSymbolNames;
@end

@implementation WCSourceHighlighter
#pragma mark *** Subclass Overrides ***
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		attributeNamesToColorSelectors = [[NSDictionary alloc] initWithObjectsAndKeys:NSStringFromSelector(@selector(plainTextColor)),WCSourceHighlighterPlainTextAttributeName,NSStringFromSelector(@selector(commentColor)),WCSourceHighlighterCommentAttributeName,NSStringFromSelector(@selector(binaryColor)),WCSourceHighlighterBinaryAttributeName,NSStringFromSelector(@selector(hexadecimalColor)),WCSourceHighlighterHexadecimalAttributeName,NSStringFromSelector(@selector(numberColor)),WCSourceHighlighterNumberAttributeName,NSStringFromSelector(@selector(mneumonicColor)),WCSourceHighlighterMneumonicAttributeName,NSStringFromSelector(@selector(directiveColor)),WCSourceHighlighterDirectiveAttributeName,NSStringFromSelector(@selector(defineColor)),WCSourceHighlighterDefineAttributeName,NSStringFromSelector(@selector(conditionalColor)),WCSourceHighlighterConditionalAttributeName,NSStringFromSelector(@selector(directiveColor)),WCSourceHighlighterDirectiveAttributeName,NSStringFromSelector(@selector(equateColor)),WCSourceHighlighterEquateAttributeName,NSStringFromSelector(@selector(labelColor)),WCSourceHighlighterLabelAttributeName,NSStringFromSelector(@selector(macroColor)),WCSourceHighlighterMacroAttributeName,NSStringFromSelector(@selector(preProcessorColor)),WCSourceHighlighterPreProcessorAttributeName,NSStringFromSelector(@selector(registerColor)),WCSourceHighlighterRegisterAttributeName,NSStringFromSelector(@selector(stringColor)),WCSourceHighlighterStringAttributeName, nil];
		attributeNamesToFontSelectors = [[NSDictionary alloc] initWithObjectsAndKeys:NSStringFromSelector(@selector(plainTextFont)),WCSourceHighlighterPlainTextAttributeName,NSStringFromSelector(@selector(commentFont)),WCSourceHighlighterCommentAttributeName,NSStringFromSelector(@selector(binaryFont)),WCSourceHighlighterBinaryAttributeName,NSStringFromSelector(@selector(hexadecimalFont)),WCSourceHighlighterHexadecimalAttributeName,NSStringFromSelector(@selector(numberFont)),WCSourceHighlighterNumberAttributeName,NSStringFromSelector(@selector(mneumonicFont)),WCSourceHighlighterMneumonicAttributeName,NSStringFromSelector(@selector(directiveFont)),WCSourceHighlighterDirectiveAttributeName,NSStringFromSelector(@selector(defineFont)),WCSourceHighlighterDefineAttributeName,NSStringFromSelector(@selector(conditionalFont)),WCSourceHighlighterConditionalAttributeName,NSStringFromSelector(@selector(directiveFont)),WCSourceHighlighterDirectiveAttributeName,NSStringFromSelector(@selector(equateFont)),WCSourceHighlighterEquateAttributeName,NSStringFromSelector(@selector(labelFont)),WCSourceHighlighterLabelAttributeName,NSStringFromSelector(@selector(macroFont)),WCSourceHighlighterMacroAttributeName,NSStringFromSelector(@selector(preProcessorFont)),WCSourceHighlighterPreProcessorAttributeName,NSStringFromSelector(@selector(registerFont)),WCSourceHighlighterRegisterAttributeName,NSStringFromSelector(@selector(stringFont)),WCSourceHighlighterStringAttributeName, nil];
	});
}

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
	
	_needsToPerformFullHighlight = YES;
	_sourceScanner = sourceScanner;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageWillProcessEditing:) name:NSTextStorageWillProcessEditingNotification object:[sourceScanner textStorage]];
	
	if ([sourceScanner needsToScanSymbols]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:sourceScanner];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanning:) name:WCSourceScannerDidFinishScanningNotification object:sourceScanner];
	}
	
	return self;
}

- (void)performFullHighlightIfNeeded; {
	if (_needsToPerformFullHighlight) {
		_needsToPerformFullHighlight = NO;
		[self performHighlightingInRange:NSMakeRange(0, [[[self sourceScanner] textStorage] length])];
	}
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
	if (![[[self sourceScanner] textStorage] length])
		return;
	
	//NSLogRange(range);
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterPlainTextAttributeName, nil] range:range];
	
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
			[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[result range]];
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateFont],NSFontAttributeName,[currentTheme equateColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterEquateAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:labelNames]) {
			[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[result range]];
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelFont],NSFontAttributeName,[currentTheme labelColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterLabelAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:macroNames]) {
			[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[result range]];
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroFont],NSFontAttributeName,[currentTheme macroColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterMacroAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:defineNames]) {
			[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[result range]];
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineFont],NSFontAttributeName,[currentTheme defineColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterDefineAttributeName, nil] range:[result range]];
		}
	}];
	
	for (WCSourceToken *token in [tokens sourceTokensForRange:range]) {
		switch ([token type]) {
			case WCSourceTokenTypeComment:
				if (NSMaxRange([token range]) > [[[self sourceScanner] textStorage] length])
					break;
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterCommentAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeBinary:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryFont],NSFontAttributeName,[currentTheme binaryColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterBinaryAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeNumber:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberFont],NSFontAttributeName,[currentTheme numberColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterNumberAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeString:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringFont],NSFontAttributeName,[currentTheme stringColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterStringAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeRegister:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerFont],NSFontAttributeName,[currentTheme registerColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterRegisterAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeDirective:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveFont],NSFontAttributeName,[currentTheme directiveColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterDirectiveAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeMneumonic:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicFont],NSFontAttributeName,[currentTheme mneumonicColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterMneumonicAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeHexadecimal:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalFont],NSFontAttributeName,[currentTheme hexadecimalColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterHexadecimalAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypePreProcessor:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorFont],NSFontAttributeName,[currentTheme preProcessorColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterPreProcessorAttributeName, nil] range:[token range]];
				break;
			case WCSourceTokenTypeConditional:
				[[[self sourceScanner] textStorage] removeAttribute:WCSourceHighlighterPlainTextAttributeName range:[token range]];
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalFont],NSFontAttributeName,[currentTheme conditionalColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterConditionalAttributeName, nil] range:[token range]];
				break;
			default:
				break;
		}
	}
	
	[[[self sourceScanner] textStorage] endEditing];
}

- (void)performHighlightingForColorWithAttributeName:(NSString *)attributeName; {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	SEL action = NSSelectorFromString([attributeNamesToColorSelectors objectForKey:attributeName]);
	NSRange range = NSMakeRange(0, [[[self sourceScanner] textStorage] length]);
	NSRange effectiveRange;
	id attributeValue;
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	while (range.length) {
		if ((attributeValue = [[[self sourceScanner] textStorage] attribute:attributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
			[[[self sourceScanner] textStorage] addAttribute:NSForegroundColorAttributeName value:[currentTheme performSelector:action] range:effectiveRange];
		}
		
		range = NSMakeRange(NSMaxRange(effectiveRange),NSMaxRange(range)-NSMaxRange(effectiveRange));
	}
	
	[[[self sourceScanner] textStorage] endEditing];
}
- (void)performHighlightingForFontWithAttributeName:(NSString *)attributeName; {	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	SEL action = NSSelectorFromString([attributeNamesToFontSelectors objectForKey:attributeName]);
	NSRange range = NSMakeRange(0, [[[self sourceScanner] textStorage] length]);
	NSRange effectiveRange;
	id attributeValue;
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	while (range.length) {
		if ((attributeValue = [[[self sourceScanner] textStorage] attribute:attributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
			[[[self sourceScanner] textStorage] addAttribute:NSFontAttributeName value:[currentTheme performSelector:action] range:effectiveRange];
		}
		
		range = NSMakeRange(NSMaxRange(effectiveRange),NSMaxRange(range)-NSMaxRange(effectiveRange));
	}
	
	[[[self sourceScanner] textStorage] endEditing];
}

- (void)performHighlightingForAllAttributes; {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSRange range = NSMakeRange(0, [[[self sourceScanner] textStorage] length]);
	NSRange effectiveRange;
	NSDictionary *attributes;
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	while (range.length) {
		if ((attributes = [[[self sourceScanner] textStorage] attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
			if ([attributes objectForKey:WCSourceHighlighterBinaryAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryFont],NSFontAttributeName,[currentTheme binaryColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterCommentAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterConditionalAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalFont],NSFontAttributeName,[currentTheme conditionalColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterDefineAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineFont],NSFontAttributeName,[currentTheme defineColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterDirectiveAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveFont],NSFontAttributeName,[currentTheme directiveColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterEquateAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateFont],NSFontAttributeName,[currentTheme equateColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterHexadecimalAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalFont],NSFontAttributeName,[currentTheme hexadecimalColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterLabelAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelFont],NSFontAttributeName,[currentTheme labelColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterMacroAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroFont],NSFontAttributeName,[currentTheme macroColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterMneumonicAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicFont],NSFontAttributeName,[currentTheme mneumonicColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterNumberAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberFont],NSFontAttributeName,[currentTheme numberColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterPlainTextAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterPreProcessorAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorFont],NSFontAttributeName,[currentTheme preProcessorColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterRegisterAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerFont],NSFontAttributeName,[currentTheme registerColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
			else if ([attributes objectForKey:WCSourceHighlighterStringAttributeName]) {
				[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringFont],NSFontAttributeName,[currentTheme stringColor],NSForegroundColorAttributeName, nil] range:effectiveRange];
			}
		}
		
		range = NSMakeRange(NSMaxRange(effectiveRange),NSMaxRange(range)-NSMaxRange(effectiveRange));
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
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterEquateAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:labelNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterLabelAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:macroNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterMacroAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:defineNames]) {
			[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineColor],NSForegroundColorAttributeName,[NSNumber numberWithBool:YES],WCSourceHighlighterDefineAttributeName, nil] range:[result range]];
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
- (void)_textStorageWillProcessEditing:(NSNotification *)note {
	if (([[note object] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	
}

- (void)_sourceScannerDidFinishScanning:(NSNotification *)note {
	//[self performHighlightingInVisibleRange];
}

- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {
	//[self performFullHighlightIfNeeded];
	[self performHighlightingInVisibleRange];
}
@end
