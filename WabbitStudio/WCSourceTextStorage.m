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
#import "WCEditorViewController.h"
#import "NSObject+WCExtensions.h"
#import "RSDefines.h"
#import "NSArray+WCExtensions.h"

@interface WCSourceTextStorage ()
- (void)_calculateLineStartIndexes;
- (void)_updateParagraphStyle;
@end

@implementation WCSourceTextStorage
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanUpUserDefaultsObserving];
	[_attributedString release];
	[_lineStartIndexes release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_attributedString = [[NSMutableAttributedString alloc] init];
	_lineStartIndexes = [[NSMutableArray alloc] init];
	
	[self setupUserDefaultsObserving];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontDidChange:) name:WCFontAndColorThemeManagerFontDidChangeNotification object:nil];
	
	[self _calculateLineStartIndexes];
	
	return self;
}

- (id)initWithString:(NSString *)string {
	[self init];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[self paragraphStyle],NSParagraphStyleAttributeName, nil]] autorelease];
	
	[_attributedString replaceCharactersInRange:NSMakeRange(0, [_attributedString length]) withAttributedString:attributedString];
	
	[self _calculateLineStartIndexes];
	
	return self;
}

- (NSString *)string; {
	return [_attributedString string];
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range; {
	return [_attributedString attributesAtIndex:location effectiveRange:range];
}
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string; {
	[_attributedString replaceCharactersInRange:range withString:string];
	[self _calculateLineStartIndexes];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:[string length] - range.length];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range; {
	[_attributedString setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)fixAttachmentAttributeInRange:(NSRange)range {
	NSRange effectiveRange;
	id attributeValue;
	while (range.length > 0) {
		if ((attributeValue = [self attribute:NSAttachmentAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
			NSUInteger charIndex;
			for (charIndex=effectiveRange.location; charIndex<NSMaxRange(effectiveRange); charIndex++) {
				if ([[self string] characterAtIndex:charIndex] != NSAttachmentCharacter)
					[self removeAttribute:NSAttachmentAttributeName range:NSMakeRange(charIndex, 1)];
			}
		}
		
		range = NSMakeRange(NSMaxRange(effectiveRange),NSMaxRange(range)-NSMaxRange(effectiveRange));
	}
}

- (NSUInteger)lineNumberForRange:(NSRange)range {
	return [[self lineStartIndexes] lineNumberForRange:range];
}

- (NSSet *)userDefaultsKeyPathsToObserve {
	return [NSSet setWithObjects:WCEditorTabWidthKey, nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorTabWidthKey]])
		[self _updateParagraphStyle];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

@dynamic paragraphStyle;
- (NSParagraphStyle *)paragraphStyle {
	NSUInteger tabWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:WCEditorTabWidthKey] unsignedIntegerValue];
	NSMutableString *tabWidthString = [NSMutableString stringWithCapacity:tabWidth];
	NSUInteger charIndex;
	
	for (charIndex=0; charIndex<tabWidth; charIndex++)
		[tabWidthString appendString:@" "];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil];
	CGFloat width = [tabWidthString sizeWithAttributes:attributes].width;
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	
	for (id item in [style tabStops])
		[style removeTabStop:item];
	
	[style setDefaultTabInterval:width];
	
	return style;
}

- (void)_calculateLineStartIndexes; {
	NSUInteger characterIndex = 0, stringLength = [[self string] length], lineEnd, contentEnd;
	
	[_lineStartIndexes removeAllObjects];
	
	// ensures we get a single line number even if the string is empty
	do {
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
		
		characterIndex = NSMaxRange([[self string] lineRangeForRange:NSMakeRange(characterIndex, 0)]);
		
	} while (characterIndex < stringLength);
	
	// Check if text ends with a new line.
	[[self string] getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineStartIndexes lastObject] unsignedIntegerValue], 0)];
	if (contentEnd < lineEnd)
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
}

- (void)_updateParagraphStyle; {
	NSParagraphStyle *style = [self paragraphStyle];
	for (NSLayoutManager *layoutManager in [self layoutManagers]) {
		for (NSTextContainer *textContainer in [layoutManager textContainers]) {
			[[textContainer textView] setDefaultParagraphStyle:style];
		}
	}
	[self addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName, nil] range:NSMakeRange(0, [self length])];
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
