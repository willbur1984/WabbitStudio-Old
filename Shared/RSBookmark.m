//
//  RSBookmark.m
//  WabbitStudio
//
//  Created by William Towe on 1/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSBookmark.h"
#import "NSString+RSExtensions.h"

@interface RSBookmark ()
@property (readwrite,assign,nonatomic) NSRange range;
@property (readwrite,assign,nonatomic) NSRange visibleRange;
@end

@implementation RSBookmark
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_textStorage = nil;
	[super dealloc];
}

+ (RSBookmark *)bookmarkWithRange:(NSRange)range visibleRange:(NSRange)visibleRange textStorage:(NSTextStorage *)textStorage; {
	return [[[[self class] alloc] initWithRange:range visibleRange:visibleRange textStorage:textStorage] autorelease];
}
- (id)initWithRange:(NSRange)range visibleRange:(NSRange)visibleRange textStorage:(NSTextStorage *)textStorage; {
	if (!(self = [super init]))
		return nil;
	
	_textStorage = textStorage;
	_range = range;
	_visibleRange = visibleRange;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textStorage];
	
	return self;
}

@synthesize textStorage=_textStorage;
@synthesize range=_range;
@synthesize visibleRange=_visibleRange;
@dynamic lineNumber;
- (NSUInteger)lineNumber {
	return [[[self textStorage] string] lineNumberForRange:[self range]];
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	if (([[self textStorage] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	
	NSRange editedRange = [[self textStorage] editedRange];
	NSInteger changeInLength = [[self textStorage] changeInLength];
	NSRange oldRange = [self range];
	
	if (NSLocationInRange(editedRange.location, [self range])) {
		[self setRange:NSMakeRange(oldRange.location, oldRange.length+changeInLength)];
	}
	else if ([self range].location >= editedRange.location) {
		[self setRange:NSMakeRange(oldRange.location+changeInLength, oldRange.length)];
	}
}

@end
