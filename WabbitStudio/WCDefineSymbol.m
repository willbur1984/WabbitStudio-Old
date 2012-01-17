//
//  WCDefineSymbol.m
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCDefineSymbol.h"
#import "WCSourceScanner.h"
#import "NSString+RSExtensions.h"

@implementation WCDefineSymbol
- (void)dealloc {
	[_value release];
	[_arguments release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@\nvalue: %@\narguments: %@",[self typeDescription],NSStringFromRange([self range]),[self name],[self value],[self arguments]];
}

- (NSString *)completionName {
	if ([self arguments])
		return [NSString stringWithFormat:@"%@(%@) = %@ \u2192 (%@:%lu)",[self name],[[self arguments] componentsJoinedByString:@","],[self value],[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1];
	else if ([self value])
		return [NSString stringWithFormat:@"%@ = %@ \u2192 (%@:%lu)",[self name],[self value],[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1];
	else
		return [NSString stringWithFormat:@"%@ \u2192 (%@:%lu)",[self name],[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1];
}
- (NSArray *)completionArguments {
	return [self arguments];
}

- (NSAttributedString *)attributedToolTip {
	NSMutableAttributedString *retval = [[[NSMutableAttributedString alloc] initWithString:[self name] attributes:RSToolTipProviderDefaultAttributes()] autorelease];
	
	[retval applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [retval length])];
	
	if ([self arguments]) {
		[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"(%@)",[[self arguments] componentsJoinedByString:@", "]] attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
		[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" = %@",[self value]] attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
	}
	else if ([self value])
		[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" = %@",[self value]] attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
	
	[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" \u2192 %@:%lu",[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1] attributes:[NSDictionary dictionaryWithObjectsAndKeys:RSToolTipProviderDefaultFont(),NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName, nil]] autorelease]];
		
	return retval;
}

+ (id)defineSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value arguments:(NSArray *)arguments; {
	return [[[[self class] alloc] initWithRange:range name:name value:value arguments:arguments] autorelease];
}
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value arguments:(NSArray *)arguments; {
	if (!(self = [super initWithType:WCSourceSymbolTypeDefine range:range name:name]))
		return nil;
	
	_value = [value copy];
	_arguments = [arguments copy];
	
	return self;
}

+ (id)defineSymbolWithRange:(NSRange)range name:(NSString *)name; {
	return [self defineSymbolWithRange:range name:name value:nil arguments:nil];
}
+ (id)defineSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value; {
	return [self defineSymbolWithRange:range name:name value:value arguments:nil];
}

@synthesize value=_value;
@synthesize arguments=_arguments;

@end
