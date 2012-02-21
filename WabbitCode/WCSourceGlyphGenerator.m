//
//  WCSourceGlyphGenerator.m
//  WabbitStudio
//
//  Created by William Towe on 1/27/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceGlyphGenerator.h"
#import "WCSourceTypesetter.h"

@implementation WCSourceGlyphGenerator
- (void)generateGlyphsForGlyphStorage:(id <NSGlyphStorage>)glyphStorage desiredNumberOfCharacters:(NSUInteger)nChars glyphIndex:(NSUInteger *)glyphIndex characterIndex:(NSUInteger *)charIndex {
	
    // Stash the original requester
    _destination = glyphStorage;
    [[NSGlyphGenerator sharedGlyphGenerator] generateGlyphsForGlyphStorage:self desiredNumberOfCharacters:nChars glyphIndex:glyphIndex characterIndex:charIndex];
    _destination = nil;
}

// NSGlyphStorage interface
- (void)insertGlyphs:(const NSGlyph *)glyphs length:(NSUInteger)length forStartingGlyphAtIndex:(NSUInteger)glyphIndex characterIndex:(NSUInteger)charIndex {	
    id attribute;
    NSRange effectiveRange;
    NSGlyph *buffer = NULL;
	
    //attribute = [[self attributedString] attribute:WCLineFoldingAttributeName atIndex:charIndex longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, charIndex + length)];
	attribute = [[self attributedString] attribute:WCLineFoldingAttributeName atIndex:charIndex effectiveRange:NULL];
	
    if ([attribute boolValue]) {
		attribute = [[self attributedString] attribute:WCLineFoldingAttributeName atIndex:charIndex longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, charIndex + length)];
		
		if ([attribute boolValue]) {
			NSInteger size = sizeof(NSGlyph) * length;
			NSGlyph aGlyph = NSNullGlyph;
			buffer = NSZoneMalloc(NULL, size);
			memset_pattern4(buffer, &aGlyph, size);
			
			if (effectiveRange.location == charIndex)
				buffer[0] = NSControlGlyph;
			glyphs = buffer;
		}
    }
	
    [_destination insertGlyphs:glyphs length:length forStartingGlyphAtIndex:glyphIndex characterIndex:charIndex];
	
    if (buffer)
		NSZoneFree(NULL, buffer);
}

- (void)setIntAttribute:(NSInteger)attributeTag value:(NSInteger)val forGlyphAtIndex:(NSUInteger)glyphIndex {
    [_destination setIntAttribute:attributeTag value:val forGlyphAtIndex:glyphIndex];
}

- (NSAttributedString *)attributedString { return [_destination attributedString]; }

- (NSUInteger)layoutOptions { return [_destination layoutOptions]; }
@end
