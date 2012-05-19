//
//  WCFontAndColorThemeManager.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/NSObject.h>

@class WCFontAndColorTheme;

extern NSString *const WCFontAndColorThemeManagerCurrentThemeDidChangeNotification;

extern NSString *const WCFontAndColorThemeManagerSelectionColorDidChangeNotification;
extern NSString *const WCFontAndColorThemeManagerBackgroundColorDidChangeNotification;
extern NSString *const WCFontAndColorThemeManagerCursorColorDidChangeNotification;
extern NSString *const WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification;

extern NSString *const WCFontAndColorThemeManagerColorDidChangeNotification;
extern NSString *const WCFontAndColorThemeManagerColorDidChangeColorNameKey;
extern NSString *const WCFontAndColorThemeManagerColorDidChangeColorTypeKey;

extern NSString *const WCFontAndColorThemeManagerFontDidChangeNotification;
extern NSString *const WCFontAndColorThemeManagerFontDidChangeFontNameKey;
extern NSString *const WCFontAndColorThemeManagerFontDidChangeFontTypeKey;

@interface WCFontAndColorThemeManager : NSObject {
	NSMutableArray *_themes;
	WCFontAndColorTheme *_currentTheme;
	NSMutableSet *_userThemeIdentifiers;
	NSHashTable *_unsavedThemes;
}
@property (readonly,nonatomic) NSArray *themes;
@property (readwrite,retain,nonatomic) WCFontAndColorTheme *currentTheme;
@property (readonly,nonatomic) NSArray *defaultThemes;

+ (WCFontAndColorThemeManager *)sharedManager;

- (BOOL)containsTheme:(WCFontAndColorTheme *)theme;
- (BOOL)saveCurrentThemes:(NSError **)outError;
@end
