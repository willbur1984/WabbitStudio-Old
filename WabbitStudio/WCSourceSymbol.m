//
//  WCSourceSymbol.m
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceSymbol.h"
#import "RSDefines.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "WCSourceScanner.h"
#import "NSString+RSExtensions.h"

@interface WCSourceSymbol ()
+ (NSImage *)_sourceSymbolIconForSourceSymbolType:(WCSourceSymbolType)sourceSymbolType;
@end

@implementation WCSourceSymbol

- (void)dealloc {
	[_name release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@",[self typeDescription],NSStringFromRange([self range]),[self name]];
}

- (NSString *)completionName {
	return [self name];
}
- (NSString *)completionInsertionName {
	return [self name];
}
- (NSImage *)completionIcon {
	return [self icon];
}

- (NSAttributedString *)attributedToolTip {
	NSMutableAttributedString *retval = [[[NSMutableAttributedString alloc] initWithString:[self name] attributes:RSToolTipProviderDefaultAttributes()] autorelease];
	
	[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" \u2192 (%@:%lu)",[[[self sourceScanner] delegate] fileDisplayNameForSourceScanner:[self sourceScanner]],[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1] attributes:[NSDictionary dictionaryWithObjectsAndKeys:RSToolTipProviderDefaultFont(),NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName, nil]] autorelease]];
	
	return retval;
}

- (NSRange)jumpInRange {
	return [self range];
}
- (NSImage *)jumpInImage {
	return [self icon];
}
- (NSString *)jumpInName {
	return [self name];
}
- (NSURL *)jumpInLocationURL {
	return [[NSURL URLWithString:[self jumpInName]] URLByAppendingPathComponent:[NSString stringWithFormat:NSLocalizedString(@"line %lu", @"jump in location url line format string"),[[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]]+1]];
}

+ (id)sourceSymbolOfType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name; {
	return [[[[self class] alloc] initWithType:type range:range name:name] autorelease];
}
- (id)initWithType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name; {
	if (!(self = [super init]))
		return nil;
	
	_type = type;
	_range = range;
	_name = [name copy];
	
	return self;
}

@synthesize sourceScanner=_sourceScanner;
@synthesize type=_type;
@synthesize range=_range;
@synthesize name=_name;
@dynamic typeDescription;
- (NSString *)typeDescription {
	switch ([self type]) {
		case WCSourceSymbolTypeLabel:
			return @"Label";
		case WCSourceSymbolTypeMacro:
			return @"Macro";
		case WCSourceSymbolTypeDefine:
			return @"Define";
		case WCSourceSymbolTypeEquate:
			return @"Equate";
		default:
			return nil;
	}
}
@dynamic icon;
- (NSImage *)icon {
	return [[self class] _sourceSymbolIconForSourceSymbolType:[self type]];
}
@dynamic lineNumber;
- (NSUInteger)lineNumber {
	return [[[[self sourceScanner] textStorage] string] lineNumberForRange:[self range]];
}

+ (NSImage *)_sourceSymbolIconForSourceSymbolType:(WCSourceSymbolType)sourceSymbolType; {
	static NSMapTable *typesToIcons;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		typesToIcons = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
	});
	
	NSImage *retval = (NSImage *)NSMapGet(typesToIcons, (const void *)(sourceSymbolType + 1));
	
	if (!retval) {
		retval = [[[NSImage alloc] initWithSize:NSSmallSize] autorelease];
		
		NSColor *baseColor;
		NSString *symbolString;
		
		switch (sourceSymbolType) {
			case WCSourceSymbolTypeLabel:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] labelColor];
				symbolString = @"L";
				break;
			case WCSourceSymbolTypeMacro:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] macroColor];
				symbolString = @"M";
				break;
			case WCSourceSymbolTypeDefine:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] defineColor];
				symbolString = @"D";
				break;
			case WCSourceSymbolTypeEquate:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] equateColor];
				symbolString = @"E";
				break;
			default:
				break;
		}
		
		CGFloat hue, saturation, brightness, alpha;
		[baseColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
		
		static const CGFloat rectRadius = 3.0;
		NSRect boundsRect = NSMakeRect(0.0, 0.0, [retval size].width, [retval size].height);
		NSColor *borderColor = [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:(brightness-0.35) alpha:alpha];
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:boundsRect xRadius:rectRadius yRadius:rectRadius];
		NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
		[style setAlignment:NSCenterTextAlignment];
		NSAttributedString *foregroundString = [[[NSAttributedString alloc] initWithString:symbolString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],NSForegroundColorAttributeName,style,NSParagraphStyleAttributeName,[NSFont fontWithName:@"Menlo" size:13.0],NSFontAttributeName, nil]] autorelease];
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowBlurRadius:2.0];
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow setShadowColor:borderColor];
		
		[retval lockFocus];
		
		[baseColor setFill];
		[path fill];
		[borderColor setStroke];
		[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(boundsRect, 0.5, 0.5) xRadius:rectRadius yRadius:rectRadius] stroke];
		
		[shadow set];
		[foregroundString drawInRect:NSCenteredRectWithSize(NSMakeSize(NSWidth(boundsRect), [foregroundString size].height), boundsRect)];
		
		[retval unlockFocus];
		
		NSMapInsert(typesToIcons, (const void *)(sourceSymbolType + 1), retval);
	}
	
	return retval;
}
@end
