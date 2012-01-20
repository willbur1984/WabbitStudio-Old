//
//  WCEquateSymbol.m
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCEquateSymbol.h"
#import "WCSourceScanner.h"
#import "NSString+RSExtensions.h"
#import "WCSourceHighlighter.h"
#import "WCFontAndColorThemeManager.h"

@interface WCEquateSymbol ()
@property (readwrite,copy,nonatomic) NSAttributedString *attributedValueString;
@end

@implementation WCEquateSymbol
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_attributedValueString release];
	[_value release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@\nvalue: %@",[self typeDescription],NSStringFromRange([self range]),[self name],[self value]];
}

- (NSString *)completionName {
	return [NSString stringWithFormat:@"%@ = %@ \u2192 (%@:%lu)",[self name],[self value],[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1];
}

- (NSAttributedString *)attributedToolTip {
	NSMutableAttributedString *retval = [[[NSMutableAttributedString alloc] initWithString:[self name] attributes:RSToolTipProviderDefaultAttributes()] autorelease];
	
	[retval applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [retval length])];
	
	[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:@" = " attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
	
	[retval appendAttributedString:[self attributedValueString]];
	
	[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" \u2192 %@:%lu",[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1] attributes:[NSDictionary dictionaryWithObjectsAndKeys:RSToolTipProviderDefaultFont(),NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName, nil]] autorelease]];
	
	return retval;
}

+ (id)equateSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value; {
	return [[[[self class] alloc] initWithRange:range name:name value:value] autorelease];
}
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value; {
	if (!(self = [super initWithType:WCSourceSymbolTypeEquate range:range name:name]))
		return nil;
	
	_value = [value copy];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	
	return self;
}

@synthesize value=_value;
@synthesize attributedValueString=_attributedValueString;
- (NSAttributedString *)attributedValueString {
	if (!_attributedValueString) {
		NSMutableAttributedString *temp = [[[NSMutableAttributedString alloc] initWithString:[self value] attributes:RSToolTipProviderDefaultAttributes()] autorelease];
		WCSourceHighlighter *highlighter = [[[self sourceScanner] delegate] sourceHighlighterForSourceScanner:[self sourceScanner]];
		
		[highlighter highlightAttributeString:temp];
		
		[self setAttributedValueString:temp];
	}
	return _attributedValueString;
}

- (void)_currentThemeDidChange:(NSNotification *)note {
	[self setAttributedValueString:nil];
}
- (void)_colorDidChange:(NSNotification *)note {
	[self setAttributedValueString:nil];
}

@end
