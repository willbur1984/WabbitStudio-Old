//
//  WCFontAndColorThemeManager.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFontAndColorThemeManager.h"
#import "WCFontAndColorTheme.h"
#import "WCFontsAndColorsViewController.h"
#import "WCMiscellaneousPerformer.h"
#import "NSObject+WCExtensions.h"

NSString *const WCFontAndColorThemeManagerCurrentThemeDidChangeNotification = @"WCFontAndColorThemeManagerCurrentThemeDidChangeNotification";

NSString *const WCFontAndColorThemeManagerSelectionColorDidChangeNotification = @"WCFontAndColorThemeManagerSelectionColorDidChangeNotification";
NSString *const WCFontAndColorThemeManagerBackgroundColorDidChangeNotification = @"WCFontAndColorThemeManagerBackgroundColorDidChangeNotification";
NSString *const WCFontAndColorThemeManagerCursorColorDidChangeNotification = @"WCFontAndColorThemeManagerCursorColorDidChangeNotification";
NSString *const WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification = @"WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification";

NSString *const WCFontAndColorThemeManagerColorDidChangeNotification = @"WCFontAndColorThemeManagerColorDidChangeNotification";
NSString *const WCFontAndColorThemeManagerColorDidChangeColorNameKey = @"colorName";
NSString *const WCFontAndColorThemeManagerFontDidChangeNotification = @"WCFontAndColorThemeManagerFontDidChangeNotification";
NSString *const WCFontAndColorThemeManagerFontDidChangeFontNameKey = @"fontName";

WCFontAndColorTheme *WCFontAndColorThemeDefaultTheme;

@interface WCFontAndColorThemeManager ()
@property (readonly,nonatomic) NSMutableArray *mutableThemes;

- (void)_setupObservingForFontAndColorTheme:(WCFontAndColorTheme *)theme;
- (void)_cleanupObservingForFontAndColorTheme:(WCFontAndColorTheme *)theme;
@end

@implementation WCFontAndColorThemeManager
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		WCFontAndColorThemeDefaultTheme = [[WCFontAndColorTheme alloc] initWithPlistRepresentation:[NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"DefaultTheme" withExtension:@"plist" subdirectory:@"FontAndColorThemes"]]];
	});
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_themes = [[NSMutableArray alloc] initWithCapacity:0];
	_identifiers = [[NSMutableSet alloc] initWithCapacity:0];
	
	for (NSURL *themeURL in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[WCMiscellaneousPerformer sharedPerformer] userFontAndColorThemesDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants error:NULL]) {
		WCFontAndColorTheme *theme = [[[WCFontAndColorTheme alloc] initWithPlistRepresentation:[NSDictionary dictionaryWithContentsOfURL:themeURL]] autorelease];
		
		if ([self containsTheme:theme])
			continue;
		
		[[self mutableThemes] addObject:theme];
	}
	
	for (NSURL *themeURL in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[WCMiscellaneousPerformer sharedPerformer] applicationFontAndColorThemesDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants error:NULL]) {
		WCFontAndColorTheme *theme = [[[WCFontAndColorTheme alloc] initWithPlistRepresentation:[NSDictionary dictionaryWithContentsOfURL:themeURL]] autorelease];
		
		if ([self containsTheme:theme])
			continue;
		
		[[self mutableThemes] addObject:theme];
	}
	
	NSString *currentIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:WCFontsAndColorsCurrentThemeIdentifierKey];
	
	if ([_identifiers containsObject:currentIdentifier]) {
		for (WCFontAndColorTheme *theme in _themes) {
			if ([[theme identifier] isEqualToString:currentIdentifier]) {
				_currentTheme = [theme retain];
				break;
			}
		}
	}
	else {
		[[self mutableThemes] addObject:WCFontAndColorThemeDefaultTheme];
		_currentTheme = [WCFontAndColorThemeDefaultTheme retain];
	}
	
	[self _setupObservingForFontAndColorTheme:_currentTheme];
	
	[_themes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]]];
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == self) {
		static NSSet *fontKeyPaths;
		static NSSet *colorKeyPaths;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			fontKeyPaths = [[NSSet alloc] initWithObjects:@"plainTextFont",@"registerFont",@"commentFont",@"preProcessorFont",@"mneumonicFont",@"directiveFont",@"numberFont",@"hexadecimalFont",@"binaryFont",@"conditionalFont",@"stringFont",@"labelFont",@"equateFont",@"defineFont",@"macroFont", nil];
			colorKeyPaths = [[NSSet alloc] initWithObjects:@"plainTextColor",@"registerColor",@"commentColor",@"preProcessorColor",@"mneumonicColor",@"directiveColor",@"numberColor",@"hexadecimalColor",@"binaryColor",@"conditionalColor",@"stringColor",@"labelColor",@"equateColor",@"defineColor",@"macroColor", nil];
		});
		
		if ([keyPath isEqualToString:@"selectionColor"])
			[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerSelectionColorDidChangeNotification object:self];
		else if ([keyPath isEqualToString:@"backgroundColor"])
			[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerBackgroundColorDidChangeNotification object:self];
		else if ([keyPath isEqualToString:@"cursorColor"])
			[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerCursorColorDidChangeNotification object:self];
		else if ([keyPath isEqualToString:@"currentLineColor"])
			[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerCurrentLineColorDidChangeNotification object:self];
		else if ([fontKeyPaths containsObject:keyPath])
			[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerFontDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:keyPath,WCFontAndColorThemeManagerFontDidChangeFontNameKey, nil]];
		else if ([colorKeyPaths containsObject:keyPath])
			[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerColorDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:keyPath,WCFontAndColorThemeManagerColorDidChangeColorNameKey, nil]];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

+ (WCFontAndColorThemeManager *)sharedManager; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (BOOL)containsTheme:(WCFontAndColorTheme *)theme; {
	return [_identifiers containsObject:[theme identifier]];
}

- (BOOL)saveCurrentThemes:(NSError **)outError; {
	NSURL *directoryURL = [[WCMiscellaneousPerformer sharedPerformer] userFontAndColorThemesDirectoryURL];
	for (WCFontAndColorTheme *theme in [self themes]) {
		NSDictionary *plist = [theme plistRepresentation];
		NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
		
		if (!data)
			return NO;
		else if (![data writeToURL:[[directoryURL URLByAppendingPathComponent:[theme name]] URLByAppendingPathExtension:@"plist"] options:NSDataWritingAtomic error:outError])
			return NO;
	}
	return YES;
}

@synthesize themes=_themes;
@dynamic mutableThemes;
- (NSMutableArray *)mutableThemes {
	return [self mutableArrayValueForKey:@"themes"];
}
- (NSUInteger)countOfThemes {
	return [_themes count];
}
- (id)objectInThemesAtIndex:(NSUInteger)index {
	return [_themes objectAtIndex:index];
}
- (void)insertObject:(WCFontAndColorTheme *)object inThemesAtIndex:(NSUInteger)index {
	[_identifiers addObject:[object identifier]];
	[_themes insertObject:object atIndex:index];
}
- (void)removeObjectFromThemesAtIndex:(NSUInteger)index {
	[_identifiers removeObject:[[_themes objectAtIndex:index] identifier]];
	[_themes removeObjectAtIndex:index];
}
- (void)insertThemes:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	for (WCFontAndColorTheme *theme in array)
		[_identifiers addObject:[theme identifier]];
	[_themes insertObjects:array atIndexes:indexes];
}
- (void)removeThemesAtIndexes:(NSIndexSet *)indexes {
	for (WCFontAndColorTheme *theme in [_themes objectsAtIndexes:indexes])
		[_identifiers removeObject:[theme identifier]];
	[_themes removeObjectsAtIndexes:indexes];
}
@dynamic currentTheme;
- (WCFontAndColorTheme *)currentTheme {
	return _currentTheme;
}
- (void)setCurrentTheme:(WCFontAndColorTheme *)currentTheme {
	if (_currentTheme == currentTheme)
		return;
	
	[self _cleanupObservingForFontAndColorTheme:_currentTheme];
	
	[_currentTheme release];
	_currentTheme = [currentTheme retain];
	
	[self _setupObservingForFontAndColorTheme:_currentTheme];
	
	[[NSUserDefaults standardUserDefaults] setObject:[_currentTheme identifier] forKey:WCFontsAndColorsCurrentThemeIdentifierKey];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:self];
}

- (void)_setupObservingForFontAndColorTheme:(WCFontAndColorTheme *)theme; {
	[theme addObserver:self forKeyPaths:[NSArray arrayWithObjects:@"selectionColor",@"backgroundColor",@"cursorColor",@"currentLineColor",@"plainTextFont",@"plainTextColor",@"commentFont",@"commentColor",@"registerFont",@"registerColor",@"mneumonicFont",@"mneumonicColor",@"stringFont",@"stringColor",@"preProcessorFont",@"preProcessorColor",@"directiveFont",@"directiveColor",@"conditionalFont",@"conditionalColor",@"numberFont",@"numberColor",@"hexadecimalFont",@"hexadecimalColor",@"binaryFont",@"binaryColor",@"stringFont",@"stringColor",@"labelFont",@"labelColor",@"equateFont",@"equateColor",@"defineFont",@"defineColor",@"macroFont",@"macroColor", nil]];
}
- (void)_cleanupObservingForFontAndColorTheme:(WCFontAndColorTheme *)theme; {
	[theme removeObserver:self forKeyPaths:[NSArray arrayWithObjects:@"selectionColor",@"backgroundColor",@"cursorColor",@"currentLineColor",@"plainTextFont",@"plainTextColor",@"commentFont",@"commentColor",@"registerFont",@"registerColor",@"mneumonicFont",@"mneumonicColor",@"stringFont",@"stringColor",@"preProcessorFont",@"preProcessorColor",@"directiveFont",@"directiveColor",@"conditionalFont",@"conditionalColor",@"numberFont",@"numberColor",@"hexadecimalFont",@"hexadecimalColor",@"binaryFont",@"binaryColor",@"stringFont",@"stringColor",@"labelFont",@"labelColor",@"equateFont",@"equateColor",@"defineFont",@"defineColor",@"macroFont",@"macroColor", nil]];
}
@end
