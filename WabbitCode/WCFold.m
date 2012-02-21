//
//  WCFold.m
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFold.h"
#import "WCSourceScanner.h"
#import "WCSourceHighlighter.h"
#import "RSDefines.h"
#import "WCFontAndColorThemeManager.h"

@interface WCFold ()
@property (readwrite,copy,nonatomic) NSAttributedString *attributedString;
@end

@implementation WCFold
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_sourceScanner = nil;
	[_attributedString release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"range: %@ level: %lu contentRange: %@",NSStringFromRange([self range]),[self level],NSStringFromRange([self contentRange])];
}
#pragma mark RSToolTipProvider
- (NSAttributedString *)attributedToolTip {
	return [self attributedString];
}
#pragma mark *** Public Methods ***
+ (id)foldOfType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange; {
	return [[[[self class] alloc] initWithType:type level:level range:range contentRange:contentRange] autorelease];
}
- (id)initWithType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange; {
	if (!(self = [super initWithRepresentedObject:nil]))
		return nil;
	
	_type = type;
	_level = level;
	_range = range;
	_contentRange = contentRange;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	
	return self;
}
#pragma mark Properties
@synthesize sourceScanner=_sourceScanner;
@synthesize type=_type;
@synthesize range=_range;
@synthesize contentRange=_contentRange;
@synthesize level=_level;
- (void)setLevel:(NSUInteger)level {
	_level = level;
	
	for (WCFold *fold in [self childNodes])
		[fold setLevel:level+1];
}
@synthesize attributedString=_attributedString;
- (NSAttributedString *)attributedString {
	if (!_attributedString) {
		NSString *string = [[[[[self sourceScanner] textStorage] string] substringWithRange:[self range]] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSMutableAttributedString *temp = [[[NSMutableAttributedString alloc] initWithString:string attributes:RSToolTipProviderDefaultAttributes()] autorelease];
		WCSourceHighlighter *highlighter = [[[self sourceScanner] delegate] sourceHighlighterForSourceScanner:[self sourceScanner]];
		
		[highlighter highlightAttributeString:temp];
		
		_attributedString = [temp copy];
	}
	return _attributedString;
}
#pragma mark *** Private Methods ***

#pragma mark Notifications
- (void)_currentThemeDidChange:(NSNotification *)note {
	[self setAttributedString:nil];
}
- (void)_colorDidChange:(NSNotification *)note {
	[self setAttributedString:nil];
}
@end
