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
NSString *const WCSourceTextStorageDidRemoveAllBookmarksNotification = @"WCSourceTextStorageDidRemoveAllBookmarksNotification";

NSString *const WCSourceTextStorageDidFoldNotification = @"WCSourceTextStorageDidFoldNotification";
NSString *const WCSourceTextStorageDidUnfoldNotification = @"WCSourceTextStorageDidUnfoldNotification";
NSString *const WCSourceTextStorageFoldRangeUserInfoKey = @"WCSourceTextStorageFoldRangeUserInfoKey";

@interface WCSourceTextStorage ()
- (void)_calculateLineStartIndexes;
- (void)_calculateLineStartIndexesStartingAtLineNumber:(NSUInteger)lineNumber;
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
                NSMutableDictionary *dict = [attributes mutableCopy];
				
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
                ++(effectiveRange.location);
				--(effectiveRange.length);
            }
			
            if (range)
				*range = effectiveRange;
        }
    }
	 
	
    return attributes;
}
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string; {
	[_attributedString replaceCharactersInRange:range withString:string];
	
	NSUInteger lineNumber = [[self lineStartIndexes] lineNumberForRange:range];
	
	[self _calculateLineStartIndexesStartingAtLineNumber:lineNumber];
	
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:[string length] - range.length];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range; {
	[_attributedString setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (BOOL)fixesAttributesLazily {
	return YES;
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
- (void)removeAllBookmarks; {
	[_bookmarks removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceTextStorageDidRemoveAllBookmarksNotification object:self];
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

- (void)foldRange:(NSRange)range; {
	[self addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCLineFoldingAttributeName, nil] range:range];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceTextStorageDidFoldNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRange:range],WCSourceTextStorageFoldRangeUserInfoKey, nil]];
}
- (BOOL)unfoldRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange; {
	NSRange mEffectiveRange = [self foldRangeForRange:range];
	
	if (mEffectiveRange.location == NSNotFound)
		return NO;
	
	[self removeAttribute:WCLineFoldingAttributeName range:mEffectiveRange];
	
	if (effectiveRange)
		*effectiveRange = mEffectiveRange;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCSourceTextStorageDidUnfoldNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRange:mEffectiveRange],WCSourceTextStorageFoldRangeUserInfoKey, nil]];
	
	return YES;
}

- (NSRange)foldRangeForRange:(NSRange)range; {
	NSRange effectiveRange;
	id attributeValue = [self attribute:WCLineFoldingAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, [self length])];
	
	if ([attributeValue boolValue])
		return effectiveRange;
	return NSNotFoundRange;
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
	_lineStartIndexes = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0], nil];
	_bookmarks = [[NSMutableArray alloc] initWithCapacity:0];
	
	[self setupUserDefaultsObserving];
	
	[self _calculateLineStartIndexes];
}

- (void)_calculateLineStartIndexes; {
	[self _calculateLineStartIndexesStartingAtLineNumber:0];
}
- (void)_calculateLineStartIndexesStartingAtLineNumber:(NSUInteger)lineNumber {
	NSUInteger characterIndex = [[_lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue], stringLength = [[self string] length], lineEnd, contentEnd;
	
	[_lineStartIndexes removeObjectsInRange:NSMakeRange(lineNumber, [_lineStartIndexes count]-lineNumber)];
	
	do {
		[_lineStartIndexes addObject:[NSNumber numberWithUnsignedInteger:characterIndex]];
		
		characterIndex = NSMaxRange([[self string] lineRangeForRange:NSMakeRange(characterIndex, 0)]);
		
	} while (characterIndex < stringLength);
	
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
	//[[[self delegate] sourceHighlighterForSourceTextStorage:self] highlightSymbolsInVisibleRange];
}
- (void)_colorDidChange:(NSNotification *)note {
	//[[[self delegate] sourceHighlighterForSourceTextStorage:self] highlightSymbolsInVisibleRange];
}
- (void)_fontDidChange:(NSNotification *)note {
	//[[[self delegate] sourceHighlighterForSourceTextStorage:self] highlightSymbolsInVisibleRange];
}
@end
