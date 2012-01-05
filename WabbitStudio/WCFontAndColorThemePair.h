//
//  WCFontAndColorThemePair.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCFontAndColorTheme;

@interface WCFontAndColorThemePair : NSObject {
	__weak WCFontAndColorTheme *_theme;
	NSString *_name;
	SEL _fontSelector;
	SEL _colorSelector;
	SEL _setFontSelector;
	SEL _setColorSelector;
}
@property (readonly,nonatomic) NSString *name;
@property (readwrite,retain,nonatomic) NSFont *font;
@property (readwrite,retain,nonatomic) NSColor *color;

+ (WCFontAndColorThemePair *)fontAndColorThemePairForTheme:(WCFontAndColorTheme *)theme name:(NSString *)name;
- (id)initWithTheme:(WCFontAndColorTheme *)theme name:(NSString *)name;
@end
