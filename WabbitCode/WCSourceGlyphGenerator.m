//
//  WCSourceGlyphGenerator.m
//  WabbitStudio
//
//  Created by William Towe on 1/27/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
