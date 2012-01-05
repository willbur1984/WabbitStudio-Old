//
//  WCSourceTextStorage.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceTextStorage.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "WCSourceHighlighter.h"
#import "NSAttributedString+WCExtensions.h"

@interface WCSourceTextStorage ()
- (void)_calculateLineStartIndexes;
@end

@implementation WCSourceTextStorage
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_attributedString release];
	[_lineStartIndexes release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_attributedString = [[NSMutableAttributedString alloc] init];
	_lineStartIndexes = [[NSMutableArray alloc] init];
	
	[self _calculateLineStartIndexes];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontDidChange:) name:WCFontAndColorThemeManagerFontDidChangeNotification object:nil];
	
	return self;
}

- (NSString *)string; {
	return [_attributedString string];
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range; {
	return [_attributedString attributesAtIndex:location effectiveRange:range];
}
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string; {
	/*
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil]] autorelease];
	[_attributedString replaceCharactersInRange:range withAttributedString:attributedString];
	 */
	[_attributedString replaceCharactersInRange:range withString:string];
	[self _calculateLineStartIndexes];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:[string length] - range.length];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range; {
	[_attributedString setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (NSUInteger)lineNumberForRange:(NSRange)range {
	NSUInteger left = 0, right = [[self lineStartIndexes] count], mid, lineStart;
	
    while ((right - left) > 1) {
        mid = (right + left) / 2;
        lineStart = [[[self lineStartIndexes] objectAtIndex:mid] unsignedIntegerValue];
        
        if (range.location < lineStart)
			right = mid;
        else if (range.location > lineStart)
			left = mid;
        else
			return mid;
    }
    return left;
}

@synthesize lineStartIndexes=_lineStartIndexes;
@dynamic delegate;
- (id<WCSourceTextStorageDelegate>)delegate {
	return _delegate;
}
- (void)setDelegate:(id<WCSourceTextStorageDelegate>)delegate {
	if (_delegate == delegate)
		return;
	
	_delegate = delegate;
	
	[super setDelegate:delegate];
}

- (void)_calculateLineStartIndexes; {
	NSUInteger characterIndex = 0, stringLength = [[self string] length], lineEnd, contentEnd;
	
	[_lineStartIndexes removeAllObjects];
	
	do {
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
		
		characterIndex = NSMaxRange([[self string] lineRangeForRange:NSMakeRange(characterIndex, 0)]);
		
	} while (characterIndex < stringLength);
	
	// Check if text ends with a new line.
	[[self string] getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineStartIndexes lastObject] unsignedIntegerValue], 0)];
	if (contentEnd < lineEnd)
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
}

- (void)_currentThemeDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[self addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [self length])];
	[[[self delegate] sourceHighlighterForSourceTextStorage:self] performHighlightingInVisibleRange];
}
- (void)_colorDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	if ([[[note userInfo] objectForKey:@"colorName"] isEqualToString:@"plainTextColor"]) {
		for (NSLayoutManager *layoutManager in [self layoutManagers]) {
			for (NSTextContainer *textContainer in [layoutManager textContainers])
				[[textContainer textView] setTextColor:[currentTheme plainTextColor]];
		}
	}
	[[[self delegate] sourceHighlighterForSourceTextStorage:self] performHighlightingInVisibleRange];
}
- (void)_fontDidChange:(NSNotification *)note {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	if ([[[note userInfo] objectForKey:@"fontName"] isEqualToString:@"plainTextFont"]) {
		for (NSLayoutManager *layoutManager in [self layoutManagers]) {
			for (NSTextContainer *textContainer in [layoutManager textContainers])
				[[textContainer textView] setFont:[currentTheme plainTextFont]];
		}
	}
	[[[self delegate] sourceHighlighterForSourceTextStorage:self] performHighlightingInVisibleRange];
}
@end
