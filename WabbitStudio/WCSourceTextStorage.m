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
#import "RSBookmark.h"
#import "NSString+RSExtensions.h"
#import "NSArray+WCExtensions.h"
#import "WCFoldAttachmentCell.h"
#import "WCSourceTypesetter.h"

NSString *const WCSourceTextStorageDidAddBookmarkNotification = @"WCSourceTextStorageDidAddBookmarkNotification";
NSString *const WCSourceTextStorageDidRemoveBookmarkNotification = @"WCSourceTextStorageDidRemoveBookmarkNotification";

@interface WCSourceTextStorage ()
- (void)_calculateLineStartIndexes;
- (void)_updateParagraphStyle;
- (void)_commonInit;
@end

@implementation WCSourceTextStorage
#pragma mark *** Subclass Overrides ***

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanUpUserDefaultsObserving];
	_delegate = nil;
	[_bookmarks release];
	[_lineStartIndexes release];
	[_attributedString release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_attributedString = [[NSMutableAttributedString alloc] init];
	
	[self _commonInit];
	
	return self;
}

- (id)initWithString:(NSString *)string {
	if (!(self = [super init]))
		return nil;
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];

	_attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[currentTheme plainTextColor],NSForegroundColorAttributeName,[self paragraphStyle],NSParagraphStyleAttributeName, nil]];
	
	[self _commonInit];
	
	return self;
}

- (NSString *)string; {
	return [_attributedString string];
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range; {
	//return [_attributedString attributesAtIndex:location effectiveRange:range];
	NSDictionary *attributes = [_attributedString attributesAtIndex:location effectiveRange:range];
	
    if ([self lineFoldingEnabled]) {
        id value;
        NSRange effectiveRange;
		
        value = [attributes objectForKey:WCLineFoldingAttributeName];
        if (value && [value boolValue]) {
            [_attributedString attribute:WCLineFoldingAttributeName atIndex:location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, [_attributedString length])];
			
            // We adds NSAttachmentAttributeName if in lineFoldingAttributeName
            if (location == effectiveRange.location) { // beginning of a folded range
                NSMutableDictionary *dict = [attributes mutableCopyWithZone:NULL];
				
				static NSTextAttachment *attachment;
				static WCFoldAttachmentCell *cell;
				static dispatch_once_t onceToken;
				dispatch_once(&onceToken, ^{
					attachment = [[NSTextAttachment alloc] init];
					cell = [[WCFoldAttachmentCell alloc] initTextCell:@""];
					
					[attachment setAttachmentCell:cell];
				});
				
                //[dict setObject:sharedAttachment forKey:NSAttachmentAttributeName];
				[dict setObject:attachment forKey:NSAttachmentAttributeName];
				
                attributes = [dict autorelease];
				
                effectiveRange.length = 1;
            } else {
                ++(effectiveRange.location); --(effectiveRange.length);
            }
			
            if (range) *range = effectiveRange;
        }
    }
	 
	
    return attributes;
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

- (void)fixParagraphStyleAttributeInRange:(NSRange)range {	
	NSRange paragraphRange = [[self string] paragraphRangeForRange:range];
	
	[self addAttribute:NSParagraphStyleAttributeName value:[self paragraphStyle] range:paragraphRange];
}

- (void)fixAttachmentAttributeInRange:(NSRange)range {
	NSRange effectiveRange;
	id attributeValue;
	while (range.length) {
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
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorTabWidthKey]])
		[self _updateParagraphStyle];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
#pragma mark *** Public Methods ***
+ (NSParagraphStyle *)defaultParagraphStyle; {
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

- (void)addBookmark:(RSBookmark *)bookmark; {
	if ([self bookmarkAtLineNumber:[bookmark lineNumber]])
		return;
	
	[_bookmarks addObject:bookmark];
	[_bookmarks sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"lineNumber" ascending:YES], nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceTextStorageDidAddBookmarkNotification object:self];
}
- (void)removeBookmark:(RSBookmark *)bookmark; {
	[_bookmarks removeObjectIdenticalTo:bookmark];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceTextStorageDidRemoveBookmarkNotification object:self];
}
- (RSBookmark *)bookmarkAtLineNumber:(NSUInteger)lineNumber; {
	if (![_bookmarks count])
		return nil;
	else if ([_bookmarks count] == 1) {
		if ([[_bookmarks lastObject] lineNumber] == lineNumber)
			return [_bookmarks lastObject];
		return nil;
	}
	else {
		NSUInteger startIndex = [_bookmarks bookmarkIndexForRange:[[self string] rangeForLineNumber:lineNumber]];
		
		for (RSBookmark *bookmark in [_bookmarks subarrayWithRange:NSMakeRange(startIndex, [_bookmarks count]-startIndex)]) {
			if ([bookmark lineNumber] == lineNumber)
				return bookmark;
			else if ([bookmark lineNumber] > lineNumber)
				break;
		}
		return nil;
	}
}
- (NSArray *)bookmarksForRange:(NSRange)range; {
	return [_bookmarks bookmarksForRange:range];
}

#pragma mark Properties
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
	return [[self class] defaultParagraphStyle];
}
@synthesize bookmarks=_bookmarks;
@dynamic lineFoldingEnabled;
- (BOOL)lineFoldingEnabled {
	return _textStorageFlags.lineFoldingEnabled;
}
- (void)setLineFoldingEnabled:(BOOL)lineFoldingEnabled {
	_textStorageFlags.lineFoldingEnabled = lineFoldingEnabled;
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	_lineStartIndexes = [[NSMutableArray alloc] initWithCapacity:0];
	_bookmarks = [[NSMutableArray alloc] initWithCapacity:0];
	
	[self setupUserDefaultsObserving];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontDidChange:) name:WCFontAndColorThemeManagerFontDidChangeNotification object:nil];
	
	[self _calculateLineStartIndexes];
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
#pragma mark Notifications
- (void)_currentThemeDidChange:(NSNotification *)note {
	[[[self delegate] sourceHighlighterForSourceTextStorage:self] performHighlightingInVisibleRange];
}
- (void)_colorDidChange:(NSNotification *)note {
	[[[self delegate] sourceHighlighterForSourceTextStorage:self] performHighlightingInVisibleRange];
}
- (void)_fontDidChange:(NSNotification *)note {
	[[[self delegate] sourceHighlighterForSourceTextStorage:self] performHighlightingInVisibleRange];
}
@end
