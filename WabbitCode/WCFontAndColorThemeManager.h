//
//  WCFontAndColorThemeManager.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
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
