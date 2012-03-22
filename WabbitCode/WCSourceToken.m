//
//  WCSourceToken.m
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceToken.h"
#import "RSDefines.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"

NSString *const WCSourceTokenTypeAttributeName = @"WCSourceTokenTypeAttributeName";

@interface WCSourceToken ()
+ (NSImage *)_sourceTokenIconForSourceTokenType:(WCSourceTokenType)sourceTokenType;
@end

@implementation WCSourceToken
#pragma mark *** Subclass Overrides ***
+ (void)initialize {
	if (self == [WCSourceToken class]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fontAndColorManagerDidChangeCurrentTheme:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification object:nil];
	}
}

- (void)dealloc {
	[_name release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@",[self typeDescription],NSStringFromRange([self range]),[self name]];
}
#pragma mark *** Public Methods ***
+ (id)sourceTokenOfType:(WCSourceTokenType)type range:(NSRange)range name:(NSString *)name; {
	return [[[[self class] alloc] initWithType:type range:range name:name] autorelease];
}
- (id)initWithType:(WCSourceTokenType)type range:(NSRange)range name:(NSString *)name; {
	if (!(self = [super init]))
		return nil;
	
	_type = type;
	_range = range;
	_name = [name copy];
	
	return self;
}

+ (NSImage *)sourceTokenIconForSourceTokenType:(WCSourceTokenType)sourceTokenType; {
	return [self _sourceTokenIconForSourceTokenType:sourceTokenType];
}
#pragma mark Properties
@synthesize type=_type;
@synthesize range=_range;
@synthesize name=_name;
@dynamic typeDescription;
- (NSString *)typeDescription {
	switch ([self type]) {
		case WCSourceTokenTypeString:
			return @"String";
		case WCSourceTokenTypeBinary:
			return @"Binary";
		case WCSourceTokenTypeHexadecimal:
			return @"Hexadecimal";
		case WCSourceTokenTypePreProcessor:
			return @"PreProcessor";
		case WCSourceTokenTypeNumber:
			return @"Number";
		case WCSourceTokenTypeComment:
			return @"Comment";
		case WCSourceTokenTypeRegister:
			return @"Register";
		case WCSourceTokenTypeDirective:
			return @"Directive";
		case WCSourceTokenTypeMneumonic:
			return @"Mneumonic";
		default:
			return nil;
	}
}
@dynamic icon;
- (NSImage *)icon {
	return [[self class] _sourceTokenIconForSourceTokenType:[self type]];
}
#pragma mark *** Private Methods ***
static NSMapTable *typesToIcons;

+ (NSImage *)_sourceTokenIconForSourceTokenType:(WCSourceTokenType)sourceTokenType; {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		typesToIcons = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
	});
	
	NSImage *retval = (NSImage *)NSMapGet(typesToIcons, (const void *)(sourceTokenType + 1));
	
	if (!retval) {
		retval = [[[NSImage alloc] initWithSize:NSSmallSize] autorelease];
		
		NSColor *baseColor;
		NSString *tokenString;
		
		switch (sourceTokenType) {
			case WCSourceTokenTypeBinary:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] binaryColor];
				tokenString = @"b";
				break;
			case WCSourceTokenTypeNumber:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] numberColor];
				tokenString = @"0";
				break;
			case WCSourceTokenTypeString:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] stringColor];
				tokenString = @"\"";
				break;
			case WCSourceTokenTypeComment:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] commentColor];
				tokenString = @";";
				break;
			case WCSourceTokenTypeRegister:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] registerColor];
				tokenString = @"r";
				break;
			case WCSourceTokenTypeDirective:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] directiveColor];
				tokenString = @"d";
				break;
			case WCSourceTokenTypeMneumonic:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] mneumonicColor];
				tokenString = @"m";
				break;
			case WCSourceTokenTypeConditional:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] conditionalColor];
				tokenString = @"c";
				break;
			case WCSourceTokenTypeHexadecimal:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] hexadecimalColor];
				tokenString = @"h";
				break;
			case WCSourceTokenTypePreProcessor:
				baseColor = [[[WCFontAndColorThemeManager sharedManager] currentTheme] preProcessorColor];
				tokenString = @"#";
				break;
			default:
				baseColor = nil;
				tokenString = @"";
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
		NSAttributedString *foregroundString = [[[NSAttributedString alloc] initWithString:tokenString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],NSForegroundColorAttributeName,style,NSParagraphStyleAttributeName,[NSFont fontWithName:@"Menlo" size:13.0],NSFontAttributeName, nil]] autorelease];
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
		
		NSMapInsert(typesToIcons, (const void *)(sourceTokenType + 1), retval);
	}
	
	return retval;
}

+ (void)_fontAndColorManagerDidChangeCurrentTheme:(NSNotification *)note {
	[typesToIcons removeAllObjects];
}

@end
