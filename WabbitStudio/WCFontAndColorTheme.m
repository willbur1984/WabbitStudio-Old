//
//  WCFontAndColorTheme.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFontAndColorTheme.h"
#import "WCColorToStringValueTransformer.h"
#import "WCFontToStringValueTransformer.h"
#import "WCFontAndColorThemePair.h"

NSString *const WCFontAndColorThemeNameKey = @"name";
NSString *const WCFontAndColorThemeIdentifierKey = @"identifier";

NSString *const WCFontAndColorThemeSelectionColorKey = @"selectionColor";
NSString *const WCFontAndColorThemeBackgroundColorKey = @"backgroundColor";
NSString *const WCFontAndColorThemeCursorColorKey = @"cursorColor";
NSString *const WCFontAndColorThemeCurrentLineColorKey = @"currentLineColor";

NSString *const WCFontAndColorThemePlainTextFontKey = @"plainTextFont";
NSString *const WCFontAndColorThemePlainTextColorKey = @"plainTextColor";
NSString *const WCFontAndColorThemeCommentFontKey = @"commentFont";
NSString *const WCFontAndColorThemeCommentColorKey = @"commentColor";
NSString *const WCFontAndColorThemeRegisterFontKey = @"registerFont";
NSString *const WCFontAndColorThemeRegisterColorKey = @"registerColor";
NSString *const WCFontAndColorThemeMneumonicFontKey = @"mneumonicFont";
NSString *const WCFontAndColorThemeMneumonicColorKey = @"mneumonicColor";
NSString *const WCFontAndColorThemeDirectiveFontKey = @"directiveFont";
NSString *const WCFontAndColorThemeDirectiveColorKey = @"directiveColor";
NSString *const WCFontAndColorThemePreProcessorFontKey = @"preProcessorFont";
NSString *const WCFontAndColorThemePreProcessorColorKey = @"preProcessorColor";
NSString *const WCFontAndColorThemeConditionalFontKey = @"conditionalFont";
NSString *const WCFontAndColorThemeConditionalColorKey = @"conditionalColor";
NSString *const WCFontAndColorThemeNumberFontKey = @"numberFont";
NSString *const WCFontAndColorThemeNumberColorKey = @"numberColor";
NSString *const WCFontAndColorThemeHexadecimalFontKey = @"hexadecimalFont";
NSString *const WCFontAndColorThemeHexadecimalColorKey = @"hexadecimalColor";
NSString *const WCFontAndColorThemeBinaryFontKey = @"binaryFont";
NSString *const WCFontAndColorThemeBinaryColorKey = @"binaryColor";
NSString *const WCFontAndColorThemeStringFontKey = @"stringFont";
NSString *const WCFontAndColorThemeStringColorKey = @"stringColor";

NSString *const WCFontAndColorThemeLabelFontKey = @"labelFont";
NSString *const WCFontAndColorThemeLabelColorKey = @"labelColor";
NSString *const WCFontAndColorThemeEquateFontKey = @"equateFont";
NSString *const WCFontAndColorThemeEquateColorKey = @"equateColor";
NSString *const WCFontAndColorThemeDefineFontKey = @"defineFont";
NSString *const WCFontAndColorThemeDefineColorKey = @"defineColor";
NSString *const WCFontAndColorThemeMacroFontKey = @"macroFont";
NSString *const WCFontAndColorThemeMacroColorKey = @"macroColor";

static WCColorToStringValueTransformer *colorToStringValueTransformer;
static WCFontToStringValueTransformer *fontToStringValueTransformer;

@implementation WCFontAndColorTheme
#pragma mark *** Subclass Overrides ***
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		colorToStringValueTransformer = [[WCColorToStringValueTransformer alloc] init];
		fontToStringValueTransformer = [[WCFontToStringValueTransformer alloc] init];
	});
}

- (void)dealloc {
	[_URL release];
	[_name release];
	[_identifier release];
	[_pairs release];
	
	[_selectionColor release];
	[_backgroundColor release];
	[_cursorColor release];
	[_currentLineColor release];
	
	[_plainTextFont release];
	[_plainTextColor release];
	[_commentFont release];
	[_commentColor release];
	[_registerFont release];
	[_registerColor release];
	[_mneumonicFont release];
	[_mneumonicColor release];
	[_directiveFont release];
	[_directiveColor release];
	[_preProcessorFont release];
	[_preProcessorColor release];
	[_conditionalFont release];
	[_conditionalColor release];
	[_numberFont release];
	[_numberColor release];
	[_hexadecimalFont release];
	[_hexadecimalColor release];
	[_binaryFont release];
	[_binaryColor release];
	[_stringFont release];
	[_stringColor release];
	
	[_labelFont release];
	[_labelColor release];
	[_equateFont release];
	[_equateColor release];
	[_defineFont release];
	[_defineColor release];
	[_macroFont release];
	[_macroColor release];
	
	[super dealloc];
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCFontAndColorTheme *copy = [[[self class] alloc] init];
	
	copy->_name = [_name copy];
	copy->_identifier = [_identifier copy];
	
	copy->_plainTextFont = [_plainTextFont retain];
	copy->_plainTextColor = [_plainTextColor retain];
	copy->_registerFont = [_registerFont retain];
	copy->_registerColor = [_registerColor retain];
	copy->_commentFont = [_commentFont retain];
	copy->_commentColor = [_commentColor retain];
	copy->_mneumonicFont = [_mneumonicFont retain];
	copy->_mneumonicColor = [_mneumonicColor retain];
	copy->_directiveFont = [_directiveFont retain];
	copy->_directiveColor = [_directiveColor retain];
	copy->_numberFont = [_numberFont retain];
	copy->_numberColor = [_numberColor retain];
	copy->_hexadecimalFont = [_hexadecimalFont retain];
	copy->_hexadecimalColor = [_hexadecimalColor retain];
	copy->_binaryFont = [_binaryFont retain];
	copy->_binaryColor = [_binaryColor retain];
	copy->_preProcessorFont = [_preProcessorFont retain];
	copy->_preProcessorColor = [_preProcessorColor retain];
	copy->_conditionalFont = [_conditionalFont retain];
	copy->_conditionalColor = [_conditionalColor retain];
	copy->_stringFont = [_stringFont retain];
	copy->_stringColor = [_stringColor retain];
	
	copy->_labelFont = [_labelFont retain];
	copy->_labelColor = [_labelColor retain];
	copy->_equateFont = [_equateFont retain];
	copy->_equateColor = [_equateColor retain];
	copy->_defineFont = [_defineFont retain];
	copy->_defineColor = [_defineColor retain];
	copy->_macroFont = [_macroFont retain];
	copy->_macroColor = [_macroColor retain];
	
	copy->_selectionColor = [_selectionColor retain];
	copy->_backgroundColor = [_backgroundColor retain];
	copy->_cursorColor = [_cursorColor retain];
	copy->_currentLineColor = [_currentLineColor retain];
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCFontAndColorTheme *copy = [[[self class] alloc] init];
	
	copy->_name = [[NSString alloc] initWithFormat:@"Copy of \"%@\"",_name];
	copy->_identifier = [[NSString alloc] initWithFormat:@"org.revsoft.wabbitstudio.fontandcolortheme.%@",_name];
	
	copy->_plainTextFont = [_plainTextFont retain];
	copy->_plainTextColor = [_plainTextColor retain];
	copy->_registerFont = [_registerFont retain];
	copy->_registerColor = [_registerColor retain];
	copy->_commentFont = [_commentFont retain];
	copy->_commentColor = [_commentColor retain];
	copy->_mneumonicFont = [_mneumonicFont retain];
	copy->_mneumonicColor = [_mneumonicColor retain];
	copy->_directiveFont = [_directiveFont retain];
	copy->_directiveColor = [_directiveColor retain];
	copy->_numberFont = [_numberFont retain];
	copy->_numberColor = [_numberColor retain];
	copy->_hexadecimalFont = [_hexadecimalFont retain];
	copy->_hexadecimalColor = [_hexadecimalColor retain];
	copy->_binaryFont = [_binaryFont retain];
	copy->_binaryColor = [_binaryColor retain];
	copy->_preProcessorFont = [_preProcessorFont retain];
	copy->_preProcessorColor = [_preProcessorColor retain];
	copy->_conditionalFont = [_conditionalFont retain];
	copy->_conditionalColor = [_conditionalColor retain];
	copy->_stringFont = [_stringFont retain];
	copy->_stringColor = [_stringColor retain];
	
	copy->_labelFont = [_labelFont retain];
	copy->_labelColor = [_labelColor retain];
	copy->_equateFont = [_equateFont retain];
	copy->_equateColor = [_equateColor retain];
	copy->_defineFont = [_defineFont retain];
	copy->_defineColor = [_defineColor retain];
	copy->_macroFont = [_macroFont retain];
	copy->_macroColor = [_macroColor retain];
	
	copy->_selectionColor = [_selectionColor retain];
	copy->_backgroundColor = [_backgroundColor retain];
	copy->_cursorColor = [_cursorColor retain];
	copy->_currentLineColor = [_currentLineColor retain];
	
	return copy;
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[retval setObject:[self name] forKey:WCFontAndColorThemeNameKey];
	[retval setObject:[self identifier] forKey:WCFontAndColorThemeIdentifierKey];
	
	[retval setObject:[colorToStringValueTransformer transformedValue:[self selectionColor]] forKey:WCFontAndColorThemeSelectionColorKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self backgroundColor]] forKey:WCFontAndColorThemeBackgroundColorKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self cursorColor]] forKey:WCFontAndColorThemeCursorColorKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self currentLineColor]] forKey:WCFontAndColorThemeCurrentLineColorKey];
	
	[retval setObject:[fontToStringValueTransformer transformedValue:[self plainTextFont]] forKey:WCFontAndColorThemePlainTextFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self plainTextColor]] forKey:WCFontAndColorThemePlainTextColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self registerFont]] forKey:WCFontAndColorThemeRegisterFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self registerColor]] forKey:WCFontAndColorThemeRegisterColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self commentFont]] forKey:WCFontAndColorThemeCommentFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self commentColor]] forKey:WCFontAndColorThemeCommentColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self mneumonicFont]] forKey:WCFontAndColorThemeMneumonicFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self mneumonicColor]] forKey:WCFontAndColorThemeMneumonicColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self directiveFont]] forKey:WCFontAndColorThemeDirectiveFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self directiveColor]] forKey:WCFontAndColorThemeDirectiveColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self numberFont]] forKey:WCFontAndColorThemeNumberFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self numberColor]] forKey:WCFontAndColorThemeNumberColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self hexadecimalFont]] forKey:WCFontAndColorThemeHexadecimalFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self hexadecimalColor]] forKey:WCFontAndColorThemeHexadecimalColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self binaryFont]] forKey:WCFontAndColorThemeBinaryFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self binaryColor]] forKey:WCFontAndColorThemeBinaryColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self preProcessorFont]] forKey:WCFontAndColorThemePreProcessorFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self preProcessorColor]] forKey:WCFontAndColorThemePreProcessorColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self conditionalFont]] forKey:WCFontAndColorThemeConditionalFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self conditionalColor]] forKey:WCFontAndColorThemeConditionalColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self stringFont]] forKey:WCFontAndColorThemeStringFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self stringColor]] forKey:WCFontAndColorThemeStringColorKey];
	
	[retval setObject:[fontToStringValueTransformer transformedValue:[self labelFont]] forKey:WCFontAndColorThemeLabelFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self labelColor]] forKey:WCFontAndColorThemeLabelColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self equateFont]] forKey:WCFontAndColorThemeEquateFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self equateColor]] forKey:WCFontAndColorThemeEquateColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self defineFont]] forKey:WCFontAndColorThemeDefineFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self defineColor]] forKey:WCFontAndColorThemeDefineColorKey];
	[retval setObject:[fontToStringValueTransformer transformedValue:[self macroFont]] forKey:WCFontAndColorThemeMacroFontKey];
	[retval setObject:[colorToStringValueTransformer transformedValue:[self macroColor]] forKey:WCFontAndColorThemeMacroColorKey];
	
	return [[retval copy] autorelease];
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_name = [[plistRepresentation objectForKey:WCFontAndColorThemeNameKey] copy];
	_identifier = [[plistRepresentation objectForKey:WCFontAndColorThemeIdentifierKey] copy];
	
	_selectionColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeSelectionColorKey]] retain];
	_backgroundColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeBackgroundColorKey]] retain];
	_cursorColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeCursorColorKey]] retain];
	_currentLineColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeCurrentLineColorKey]] retain];
	
	_plainTextFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemePlainTextFontKey]] retain];
	_plainTextColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemePlainTextColorKey]] retain];
	_commentFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeCommentFontKey]] retain];
	_commentColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeCommentColorKey]] retain];
	_registerFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeRegisterFontKey]] retain];
	_registerColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeRegisterColorKey]] retain];
	_mneumonicFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeMneumonicFontKey]] retain];
	_mneumonicColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeMneumonicColorKey]] retain];
	_directiveFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeDirectiveFontKey]] retain];
	_directiveColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeDirectiveColorKey]] retain];
	_preProcessorFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemePreProcessorFontKey]] retain];
	_preProcessorColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemePreProcessorColorKey]] retain];
	_conditionalFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeConditionalFontKey]] retain];
	_conditionalColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeConditionalColorKey]] retain];
	_numberFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeNumberFontKey]] retain];
	_numberColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeNumberColorKey]] retain];
	_hexadecimalFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeHexadecimalFontKey]] retain];
	_hexadecimalColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeHexadecimalColorKey]] retain];
	_binaryFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeBinaryFontKey]] retain];
	_binaryColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeBinaryColorKey]] retain];
	_stringFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeStringFontKey]] retain];
	_stringColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeStringColorKey]] retain];
	
	_labelFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeLabelFontKey]] retain];
	_labelColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeLabelColorKey]] retain];
	_equateFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeEquateFontKey]] retain];
	_equateColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeEquateColorKey]] retain];
	_defineFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeDefineFontKey]] retain];
	_defineColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeDefineColorKey]] retain];
	_macroFont = [[fontToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeMacroFontKey]] retain];
	_macroColor = [[colorToStringValueTransformer reverseTransformedValue:[plistRepresentation objectForKey:WCFontAndColorThemeMacroColorKey]] retain];
	
	return self;
}
#pragma mark *** Public Methods ***
+ (WCFontAndColorTheme *)fontAndColorThemeWithContentsOfURL:(NSURL *)url; {
	return [[[[self class] alloc] initWithContentsOfURL:url] autorelease];
}
- (id)initWithContentsOfURL:(NSURL *)url; {
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfURL:url];
	if (!plist) {
		[self release];
		return nil;
	}
	
	_URL = [url copy];
	
	return [self initWithPlistRepresentation:plist];
}
#pragma mark Properties
@synthesize URL=_URL;
@synthesize name=_name;
@synthesize identifier=_identifier;
@dynamic pairs;
- (NSArray *)pairs {
	if (!_pairs) {
		_pairs = [[NSMutableArray alloc] initWithCapacity:0];
		
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"plainText"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"comment"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"register"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"directive"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"mneumonic"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"preProcessor"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"number"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"hexadecimal"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"binary"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"conditional"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"string"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"label"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"equate"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"define"]];
		[_pairs addObject:[WCFontAndColorThemePair fontAndColorThemePairForTheme:self name:@"macro"]];
	}
	return [[_pairs copy] autorelease];
}

@synthesize selectionColor=_selectionColor;
@synthesize backgroundColor=_backgroundColor;
@synthesize cursorColor=_cursorColor;
@synthesize currentLineColor=_currentLineColor;

@synthesize plainTextFont=_plainTextFont;
@synthesize plainTextColor=_plainTextColor;
@synthesize commentFont=_commentFont;
@synthesize commentColor=_commentColor;
@synthesize registerFont=_registerFont;
@synthesize registerColor=_registerColor;
@synthesize mneumonicFont=_mneumonicFont;
@synthesize mneumonicColor=_mneumonicColor;
@synthesize directiveFont=_directiveFont;
@synthesize directiveColor=_directiveColor;
@synthesize preProcessorFont=_preProcessorFont;
@synthesize preProcessorColor=_preProcessorColor;
@synthesize conditionalFont=_conditionalFont;
@synthesize conditionalColor=_conditionalColor;
@synthesize numberFont=_numberFont;
@synthesize numberColor=_numberColor;
@synthesize hexadecimalFont=_hexadecimalFont;
@synthesize hexadecimalColor=_hexadecimalColor;
@synthesize binaryFont=_binaryFont;
@synthesize binaryColor=_binaryColor;
@synthesize stringFont=_stringFont;
@synthesize stringColor=_stringColor;

@synthesize labelFont=_labelFont;
@synthesize labelColor=_labelColor;
@synthesize equateFont=_equateFont;
@synthesize equateColor=_equateColor;
@synthesize defineFont=_defineFont;
@synthesize defineColor=_defineColor;
@synthesize macroFont=_macroFont;
@synthesize macroColor=_macroColor;

@end
