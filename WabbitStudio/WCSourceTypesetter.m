//
//  WCSourceTypesetter.m
//  WabbitStudio
//
//  Created by William Towe on 1/27/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceTypesetter.h"
#import "WCSourceTextStorage.h"
#import "RSDefines.h"

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
