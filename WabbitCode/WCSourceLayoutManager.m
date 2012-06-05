//
//  WCSourceLayoutManager.m
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

#import "WCSourceLayoutManager.h"
#import "WCSourceTypesetter.h"
#import "WCSourceGlyphGenerator.h"
#import "WCSourceTextStorage.h"

@implementation WCSourceLayoutManager
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	WCSourceTypesetter *typesetter = [[[WCSourceTypesetter alloc] init] autorelease];
	
	[self setTypesetter:typesetter];
	
	WCSourceGlyphGenerator *glyphGenerator = [[[WCSourceGlyphGenerator alloc] init] autorelease];
	
	[self setGlyphGenerator:glyphGenerator];
	
	return self;
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {
    NSTextStorage *textStorage = [self textStorage];
    
    [(WCSourceTextStorage *)textStorage setLineFoldingEnabled:YES];
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    [(WCSourceTextStorage *)textStorage setLineFoldingEnabled:NO];
}

// -textStorage:edited:range:changeInLength:invalidatedRange: delegate method invoked from NSTextStorage notifies layout managers whenever there was a modifications.  Based on the notification, NSLayoutManager invalidates cached internal information.  With normal circumstances, NSLayoutManager extends the invalidated range to nearest paragraph boundaries.  Since -[LineFoldingTypesetter actionForCharacterAtIndex:] might change the paragraph separator behavior, we need to make sure that the invalidation is covering the visible line range.
- (void)textStorage:(NSTextStorage *)str edited:(NSUInteger)editedMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange {
    NSUInteger length = [str length];
    NSNumber *value;
    NSRange effectiveRange, range;
	
    if ((invalidatedCharRange.location == length) && (invalidatedCharRange.location != 0)) { // it's at the end. check if the last char is in lineFoldingAttributeName
        value = [str attribute:WCLineFoldingAttributeName atIndex:invalidatedCharRange.location - 1 effectiveRange:&effectiveRange];
		
        if (value && [value boolValue])
            invalidatedCharRange = NSUnionRange(invalidatedCharRange, effectiveRange);
    }
	
    if (invalidatedCharRange.location < length) {
        NSString *string = [str string];
        NSUInteger start, end;
		
        if (delta > 0) {
            NSUInteger contentsEnd;
			
            [string getParagraphStart:NULL end:&end contentsEnd:&contentsEnd forRange:newCharRange];
			
            if ((contentsEnd != end) && (invalidatedCharRange.location > 0) && (NSMaxRange(newCharRange) == end)) { // there was para sep insertion. extend to both sides
                if (newCharRange.location <= invalidatedCharRange.location) {
                    invalidatedCharRange.length = (NSMaxRange(invalidatedCharRange) - (newCharRange.location - 1));
                    invalidatedCharRange.location = (newCharRange.location - 1);
                }
				
                if ((end < length) && (NSMaxRange(invalidatedCharRange) <= end)) {
                    invalidatedCharRange.length = ((end + 1) - invalidatedCharRange.location);
                }
            }
        }
		
        range = invalidatedCharRange;
		
        while ((range.location > 0) || (NSMaxRange(range) < length)) {
            [string getParagraphStart:&start end:&end contentsEnd:NULL forRange:range];
            range.location = start;
            range.length = (end - start);
			
            // Extend backward
            value = [str attribute:WCLineFoldingAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, range.location + 1)];
            if (value && [value boolValue] && (effectiveRange.location < range.location)) {
                range.length += (range.location - effectiveRange.location);
                range.location = effectiveRange.location;
            }
			
            // Extend forward
            if (NSMaxRange(range) < length) {
                value = [str attribute:WCLineFoldingAttributeName atIndex:NSMaxRange(range) longestEffectiveRange:&effectiveRange inRange:NSMakeRange(NSMaxRange(range), length - NSMaxRange(range))];
                if (value && [value boolValue] && (NSMaxRange(effectiveRange) > NSMaxRange(range))) {
                    range.length = NSMaxRange(effectiveRange) - range.location;
                }
            }
			
            if (NSEqualRanges(range, invalidatedCharRange))
                break;
            
            invalidatedCharRange = range;
        }
    }
	
    [super textStorage:str edited:editedMask range:newCharRange changeInLength:delta invalidatedRange:invalidatedCharRange];
}
@end
