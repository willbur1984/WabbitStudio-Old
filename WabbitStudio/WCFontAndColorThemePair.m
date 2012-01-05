//
//  WCFontAndColorThemePair.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFontAndColorThemePair.h"
#import "WCFontAndColorTheme.h"
#import "NSString+WCExtensions.h"

static NSDictionary *FontAndColorTypesToNames;

@implementation WCFontAndColorThemePair
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		FontAndColorTypesToNames = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"FontAndColorThemeTypesToNames" withExtension:@"plist"]];
	});
}

- (void)dealloc {
	_colorSelector = NULL;
	_fontSelector = NULL;
	_setColorSelector = NULL;
	_setFontSelector = NULL;
	_theme = nil;
	[_name release];
	[super dealloc];
}

+ (WCFontAndColorThemePair *)fontAndColorThemePairForTheme:(WCFontAndColorTheme *)theme name:(NSString *)name; {
	return [[[[self class] alloc] initWithTheme:theme name:name] autorelease];
}
- (id)initWithTheme:(WCFontAndColorTheme *)theme name:(NSString *)name; {
	if (!(self = [super init]))
		return nil;
	
	_theme = theme;
	_name = [name copy];
	_colorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",name]);
	_fontSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Font",name]);
	_setColorSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@Color:",[name camelCaseString]]);
	_setFontSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@Font:",[name camelCaseString]]);
	
	return self;
}

@dynamic name;
- (NSString *)name {
	return [FontAndColorTypesToNames objectForKey:_name];
}
@dynamic color;
- (NSColor *)color {
	return [_theme performSelector:_colorSelector];
}
- (void)setColor:(NSColor *)color {
	[_theme performSelector:_setColorSelector withObject:color];
}
@dynamic font;
- (NSFont *)font {
	return [_theme performSelector:_fontSelector];
}
- (void)setFont:(NSFont *)font {
	[_theme performSelector:_setFontSelector withObject:font];
}
@end
