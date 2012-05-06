//
//  WCSourceTypesetter.m
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

#import "WCSourceTypesetter.h"
#import "WCSourceTextStorage.h"
#import "RSDefines.h"
#import "WCFold.h"
#import "WCSourceScanner.h"

NSString *const WCLineFoldingAttributeName = @"WCLineFoldingAttributeName";

@implementation WCSourceTypesetter

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	return self;
}

- (NSTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(NSUInteger)charIndex {
	id attributeValue = [[self attributedString] attribute:WCLineFoldingAttributeName atIndex:charIndex effectiveRange:NULL];
	
	if ([attributeValue boolValue])
		return NSTypesetterZeroAdvancementAction;
	
    return [super actionForControlCharacterAtIndex:charIndex];
}

- (NSUInteger)layoutParagraphAtPoint:(NSPointPointer)lineFragmentOrigin {
    id attrString = [self attributedString];
    NSUInteger result;
	
    [attrString setLineFoldingEnabled:YES];
    result = [super layoutParagraphAtPoint:lineFragmentOrigin];
    [attrString setLineFoldingEnabled:NO];
	
    return result;
}

@end
