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
#import "WCSourceTextStorage.h"
#import "WCSourceSymbol.h"

@interface WCSourceHighlighter ()
@property (readonly,nonatomic) WCSourceScanner *sourceScanner;

- (void)_highlightInRange:(NSRange)range;
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
	
	_needsToPerformFullHighlight = YES;
	_sourceScanner = sourceScanner;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[sourceScanner textStorage]];
	
	if ([sourceScanner needsToScanSymbols]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:sourceScanner];
	}
	else {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanning:) name:WCSourceScannerDidFinishScanningNotification object:sourceScanner];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontDidChange:) name:WCFontAndColorThemeManagerFontDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidFold:) name:WCSourceTextStorageDidFoldNotification object:[sourceScanner textStorage]];
	
	return self;
}

- (void)performFullHighlightIfNeeded; {
	if (_needsToPerformFullHighlight) {
		_needsToPerformFullHighlight = NO;
		[self _highlightInRange:NSMakeRange(0, [[[self sourceScanner] textStorage] length])];
	}
}
- (void)highlightTokensInRange:(NSRange)range; {
	[self _highlightInRange:range];
}

- (void)highlightSymbolsInVisibleRange; {
	NSMutableIndexSet *ranges = [NSMutableIndexSet indexSet];
	for (NSLayoutManager *layoutManager in [[[self sourceScanner] textStorage] layoutManagers]) {
		for (NSTextContainer *textContainer in [layoutManager textContainers]) {
			[ranges addIndexesInRange:[[textContainer textView] visibleRange]];
		}
	}
	[ranges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
		[self highlightSymbolsInRange:range];
	}];
}

- (void)highlightSymbolsInRange:(NSRange)range; {
	if (!range.length)
		return;
	
	[[[self sourceScanner] textStorage] beginEditing];
	
	[[[self sourceScanner] textStorage] removeAttribute:WCSourceSymbolTypeAttributeName range:range];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	NSArray *labelNames = [[self delegate] labelSymbolsForSourceHighlighter:self];
	NSArray *equateNames = [[self delegate] equateSymbolsForSourceHighlighter:self];	
	NSArray *defineNames = [[self delegate] defineSymbolsForSourceHighlighter:self];
	NSArray *macroNames = [[self delegate] macroSymbolsForSourceHighlighter:self];
	
	[[WCSourceScanner symbolRegularExpression] enumerateMatchesInString:[[[self sourceScanner] textStorage] string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		id tokenType = [[[self sourceScanner] textStorage] attribute:WCSourceTokenTypeAttributeName atIndex:[result range].location effectiveRange:NULL];
		if (tokenType && [tokenType unsignedIntValue] != WCSourceTokenTypeNone)
			return;
		
		NSString *name = [[[[[self sourceScanner] textStorage] string] substringWithRange:[result range]] lowercaseString];
		
		if ([self _symbolName:name existsInArrayOfSymbolNames:equateNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme equateFont],NSFontAttributeName,[currentTheme equateColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceSymbolTypeEquate],WCSourceSymbolTypeAttributeName, nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:labelNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme labelFont],NSFontAttributeName,[currentTheme labelColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceSymbolTypeLabel],WCSourceSymbolTypeAttributeName,nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:macroNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme macroFont],NSFontAttributeName,[currentTheme macroColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceSymbolTypeMacro],WCSourceSymbolTypeAttributeName,nil] range:[result range]];
		}
		else if ([self _symbolName:name existsInArrayOfSymbolNames:defineNames]) {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme defineFont],NSFontAttributeName,[currentTheme defineColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceSymbolTypeDefine],WCSourceSymbolTypeAttributeName,nil] range:[result range]];
		}
		else {
			[[[self sourceScanner] textStorage] addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceSymbolTypeNone],WCSourceSymbolTypeAttributeName,nil] range:[result range]];
		}
	}];
	
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
	[[WCSourceScanner commentRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
	[[WCSourceScanner multilineCommentRegularExpression] enumerateMatchesInString:[attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentColor],NSForegroundColorAttributeName, nil] range:[result range]];
	}];
}
#pragma mark Properties
@synthesize sourceScanner=_sourceScanner;
@synthesize delegate=_delegate;
#pragma mark *** Private Methods ***
- (void)_highlightInRange:(NSRange)range; {	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSTextStorage *textStorage = [[self sourceScanner] textStorage];
	
	[textStorage beginEditing];
	
	[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeNone],WCSourceTokenTypeAttributeName, nil] range:range];
	
	[[WCSourceScanner registerRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerFont],NSFontAttributeName,[currentTheme registerColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeRegister],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner conditionalRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalFont],NSFontAttributeName,[currentTheme conditionalColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeConditional],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner mnemonicRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicFont],NSFontAttributeName,[currentTheme mneumonicColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeMneumonic],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner directiveRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveFont],NSFontAttributeName,[currentTheme directiveColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeDirective],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner numberRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberFont],NSFontAttributeName,[currentTheme numberColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeNumber],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner binaryRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryFont],NSFontAttributeName,[currentTheme binaryColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeBinary],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner hexadecimalRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalFont],NSFontAttributeName,[currentTheme hexadecimalColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeHexadecimal],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner preProcessorRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorFont],NSFontAttributeName,[currentTheme preProcessorColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypePreProcessor],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner stringRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringFont],NSFontAttributeName,[currentTheme stringColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeString],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner commentRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeComment],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[[WCSourceScanner multilineCommentRegularExpression] enumerateMatchesInString:[textStorage string] options:0 range:NSMakeRange(0, [[[self sourceScanner] textStorage] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if ([result range].location > NSMaxRange(range)) {
			*stop = YES;
			return;
		}
		else if (NSIntersectionRange([result range], range).length)
			[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName,[NSNumber numberWithUnsignedInt:WCSourceTokenTypeMultilineComment],WCSourceTokenTypeAttributeName, nil] range:[result range]];
	}];
	
	[textStorage endEditing];
}

- (BOOL)_symbolName:(NSString *)symbolName existsInArrayOfSymbolNames:(NSArray *)arrayOfSymbolNames; {
	for (NSDictionary *symbolNames in arrayOfSymbolNames) {
		if ([symbolNames objectForKey:symbolName])
			return YES;
	}
	return NO;
}
#pragma mark Notifications
- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	if (([[note object] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	else if (![[note object] length])
		return;
	//else
	//	return;
	
	NSRange editedRange = [[note object] editedRange];
	NSInteger changeInLength = [[note object] changeInLength];
	NSUInteger stringLength = [[note object] length];
	NSInteger delta;
	
	if (changeInLength < 0 && NSMaxRange(editedRange) >= stringLength) {
		delta = editedRange.location + changeInLength;
		
		if (delta < 0)
			delta = 0;
		
		editedRange.location = delta;
	}
	else if (NSMaxRange(editedRange) > stringLength) {
		if (changeInLength < 0) {
			delta = editedRange.location + changeInLength;
			
			if (delta < 0)
				delta = 0;
			
			editedRange.location = delta;
		}
		else if (changeInLength > 0) {
			delta = editedRange.location - changeInLength;
			
			if (delta < 0)
				delta = 0;
			
			editedRange.location = delta;
		}
	}
	
	NSRange lineRange = [[[note object] string] lineRangeForRange:editedRange];
	if (lineRange.location != editedRange.location) {
		delta = editedRange.location;
		
		if ((--delta) < 0)
			delta = 0;
		
		editedRange.location = delta;
	}
	
	NSRange tokenRange;
	id tokenType = [[note object] attribute:WCSourceTokenTypeAttributeName atIndex:editedRange.location longestEffectiveRange:&tokenRange inRange:NSMakeRange(0, [[note object] length])];
	
	if ([tokenType unsignedIntValue] == WCSourceTokenTypeMultilineComment)
		tokenRange = [[[note object] string] lineRangeForRange:tokenRange];
	else
		tokenRange = lineRange;
	
	[self _highlightInRange:tokenRange];
}

- (void)_sourceScannerDidFinishScanning:(NSNotification *)note {
	//[self performHighlightingInVisibleRange];
}

- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {
	//[self performFullHighlightIfNeeded];
	[self highlightSymbolsInVisibleRange];
}
- (void)_textStorageDidFold:(NSNotification *)note {
	[self highlightSymbolsInVisibleRange];
}
- (void)_currentThemeDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme]; 
	NSTextStorage *textStorage = [[self sourceScanner] textStorage];
	
	[textStorage beginEditing];
	
	[textStorage enumerateAttribute:WCSourceTokenTypeAttributeName inRange:NSMakeRange(0, [textStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id tokenType, NSRange range, BOOL *stop) {
		switch ([tokenType unsignedIntValue]) {
			case WCSourceTokenTypeNone:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeBinary:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme binaryFont],NSFontAttributeName,[currentTheme binaryColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeComment:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeConditional:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme conditionalFont],NSFontAttributeName,[currentTheme conditionalColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeDirective:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme directiveFont],NSFontAttributeName,[currentTheme directiveColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeHexadecimal:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme hexadecimalFont],NSFontAttributeName,[currentTheme hexadecimalColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeMneumonic:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme mneumonicFont],NSFontAttributeName,[currentTheme mneumonicColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeMultilineComment:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme commentFont],NSFontAttributeName,[currentTheme commentColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeNumber:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme numberFont],NSFontAttributeName,[currentTheme numberColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypePreProcessor:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme preProcessorFont],NSFontAttributeName,[currentTheme preProcessorColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeRegister:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme registerFont],NSFontAttributeName,[currentTheme registerColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			case WCSourceTokenTypeString:
				[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme stringFont],NSFontAttributeName,[currentTheme stringColor],NSForegroundColorAttributeName, nil] range:range];
				break;
			default:
				break;
		}
	}];
	
	[self highlightSymbolsInVisibleRange];
	
	[textStorage endEditing];
}
- (void)_colorDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme]; 
	NSTextStorage *textStorage = [[self sourceScanner] textStorage];
	WCSourceTokenType tokenTypeToChange = [[[note userInfo] objectForKey:WCFontAndColorThemeManagerColorDidChangeColorTypeKey] unsignedIntValue];
	SEL colorSelector = NSSelectorFromString([[note userInfo] objectForKey:WCFontAndColorThemeManagerColorDidChangeColorNameKey]);
	
	[textStorage beginEditing];
	
	[textStorage enumerateAttribute:WCSourceTokenTypeAttributeName inRange:NSMakeRange(0, [textStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id tokenType, NSRange range, BOOL *stop) {
		if ([tokenType unsignedIntValue] == tokenTypeToChange)
			[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme performSelector:colorSelector],NSForegroundColorAttributeName, nil] range:range];
		else if ([tokenType unsignedIntValue] == WCSourceTokenTypeMultilineComment &&
				 tokenTypeToChange == WCSourceTokenTypeComment)
			[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme performSelector:colorSelector],NSForegroundColorAttributeName, nil] range:range];
	}];
	
	[textStorage endEditing];
	
	[self highlightSymbolsInVisibleRange];
}
- (void)_fontDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme]; 
	NSTextStorage *textStorage = [[self sourceScanner] textStorage];
	WCSourceTokenType tokenTypeToChange = [[[note userInfo] objectForKey:WCFontAndColorThemeManagerFontDidChangeFontTypeKey] unsignedIntValue];
	SEL fontSelector = NSSelectorFromString([[note userInfo] objectForKey:WCFontAndColorThemeManagerFontDidChangeFontNameKey]);
	
	[textStorage beginEditing];
	
	[textStorage enumerateAttribute:WCSourceTokenTypeAttributeName inRange:NSMakeRange(0, [textStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id tokenType, NSRange range, BOOL *stop) {
		if ([tokenType unsignedIntValue] == tokenTypeToChange)
			[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme performSelector:fontSelector],NSFontAttributeName, nil] range:range];
		else if ([tokenType unsignedIntValue] == WCSourceTokenTypeMultilineComment &&
				 tokenTypeToChange == WCSourceTokenTypeComment)
			[textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme performSelector:fontSelector],NSFontAttributeName, nil] range:range];
				 
	}];
	
	[textStorage endEditing];
	
	[self highlightSymbolsInVisibleRange];
}
@end
