//
//  RSBookmark.m
//  WabbitStudio
//
//  Created by William Towe on 1/19/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSBookmark.h"
#import "NSString+RSExtensions.h"

@interface RSBookmark ()
@property (readwrite,assign,nonatomic) NSRange range;
@property (readwrite,assign,nonatomic) NSRange visibleRange;
@end

@implementation RSBookmark
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_textStorage = nil;
	[super dealloc];
}
#pragma mark *** Public Methods ***
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
#pragma mark Properties
@synthesize textStorage=_textStorage;
@synthesize range=_range;
@synthesize visibleRange=_visibleRange;
@dynamic lineNumber;
- (NSUInteger)lineNumber {
	return [[[self textStorage] string] lineNumberForRange:[self range]];
}
#pragma mark *** Private Methods ***

#pragma mark Notifications
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
