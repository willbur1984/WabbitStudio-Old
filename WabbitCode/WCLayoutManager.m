//
//  WCLayoutManager.m
//  WabbitStudio
//
//  Created by William Towe on 1/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCLayoutManager.h"
#import "NSString+RSExtensions.h"
#import "WCFontAndColorThemeManager.h"
#import "WCFontAndColorTheme.h"
#import "NSObject+WCExtensions.h"
#import "WCEditorViewController.h"

@implementation WCLayoutManager
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[self cleanUpUserDefaultsObserving];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	//[self setBackgroundLayoutEnabled:YES];
	[self setAllowsNonContiguousLayout:YES];
	[self setShowsInvisibleCharacters:[[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowInvisibleCharactersKey]];
	
	[self setupUserDefaultsObserving];
	
	return self;
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {	
	[super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
	
	if ([self showsInvisibleCharacters]) {
		WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName, nil];
		NSString *string = [[self textStorage] string];
		NSUInteger glyphIndex;
		
		for (glyphIndex=glyphsToShow.location; glyphIndex<NSMaxRange(glyphsToShow); glyphIndex++) {
			unichar stringChar = [string characterAtIndex:glyphIndex];
			NSPoint drawPoint;
			NSRect lineRect;
			
			switch (stringChar) {
				case '\t':
					drawPoint = [self locationForGlyphAtIndex:glyphIndex];
					lineRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
					drawPoint.x += NSMinX(lineRect);
					drawPoint.y = NSMinY(lineRect);
					
					[[NSString tabUnicodeCharacterString] drawAtPoint:drawPoint withAttributes:attributes];
					break;
				case ' ':
					drawPoint = [self locationForGlyphAtIndex:glyphIndex];
					lineRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
					drawPoint.x += NSMinX(lineRect);
					drawPoint.y = NSMinY(lineRect);
					
					[[NSString spaceUnicodeCharacterString] drawAtPoint:drawPoint withAttributes:attributes];
					break;
				case '\r':
				case '\n':
					drawPoint = [self locationForGlyphAtIndex:glyphIndex];
					lineRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
					drawPoint.x += NSMinX(lineRect);
					drawPoint.y = NSMinY(lineRect);
					
					[[NSString returnUnicodeCharacterString] drawAtPoint:drawPoint withAttributes:attributes];
					break;
				default:
					break;
			}
		}
	}
}

- (NSSet *)userDefaultsKeyPathsToObserve {
	return [NSSet setWithObjects:WCEditorShowInvisibleCharactersKey, nil];
}

#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:[kUserDefaultsKeyPathPrefix stringByAppendingString:WCEditorShowInvisibleCharactersKey]])
		[self setShowsInvisibleCharacters:[[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowInvisibleCharactersKey]];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
@end
