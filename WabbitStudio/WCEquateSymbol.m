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

@implementation WCEquateSymbol
- (void)dealloc {
	[_value release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@\nvalue: %@",[self typeDescription],NSStringFromRange([self range]),[self name],[self value]];
}

- (NSString *)completionName {
	return [NSString stringWithFormat:@"%@ = %@",[self name],[self value]];
}

- (NSAttributedString *)attributedToolTip {
	NSMutableAttributedString *retval = [[[NSMutableAttributedString alloc] initWithString:[self name] attributes:RSToolTipProviderDefaultAttributes()] autorelease];
	
	[retval applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [retval length])];
	
	[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" = %@",[self value]] attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
	
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
	
	return self;
}

@synthesize value=_value;
@end
