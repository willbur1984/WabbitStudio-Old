//
//  WCSourceTypesetter.m
//  WabbitStudio
//
//  Created by William Towe on 1/27/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceTypesetter.h"
#import "WCSourceTextStorage.h"

NSString *const WCLineFoldingAttributeName = @"WCLineFoldingAttributeName";

@implementation WCSourceTypesetter

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	return self;
}

- (NSTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(NSUInteger)charIndex {
    id attribute = [[self attributedString] attribute:WCLineFoldingAttributeName atIndex:charIndex effectiveRange:NULL];
    
    if (attribute && [attribute boolValue]) return NSTypesetterZeroAdvancementAction;
	
    return [super actionForControlCharacterAtIndex:charIndex];
}

- (NSUInteger)layoutParagraphAtPoint:(NSPointPointer)lineFragmentOrigin {
    id attrString = ([attributedString respondsToSelector:@selector(setLineFoldingEnabled:)] ? attributedString : nil);
    NSUInteger result;
	
    [attrString setLineFoldingEnabled:YES];
    result = [super layoutParagraphAtPoint:lineFragmentOrigin];
    [attrString setLineFoldingEnabled:NO];
	
    return result;
}

@end
