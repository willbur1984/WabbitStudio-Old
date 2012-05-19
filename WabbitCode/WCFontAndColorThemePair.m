//
//  WCFontAndColorThemePair.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCFontAndColorThemePair.h"
#import "WCFontAndColorTheme.h"
#import "NSString+RSExtensions.h"

static NSDictionary *FontAndColorTypesToNames;

@implementation WCFontAndColorThemePair
#pragma mark *** Subclass Overrides ***
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
#pragma mark *** Public Methods ***
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
	_setColorSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@Color:",[name stringByCapitalizingFirstLetter]]);
	_setFontSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@Font:",[name stringByCapitalizingFirstLetter]]);
	
	return self;
}
#pragma mark Properties
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
