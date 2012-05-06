//
//  RSVerticallyCenteredTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 4/21/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSVerticallyCenteredTextFieldCell.h"
#import "RSDefines.h"


@implementation RSVerticallyCenteredTextFieldCell
#pragma mark *** Subclass Overrides ***
- (id)initTextCell:(NSString *)stringValue {
	if (!(self = [super initTextCell:stringValue]))
		return nil;
	
	[self commonInit];
	
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {	
	[super drawInteriorWithFrame:[self centeredTitleRectForBounds:cellFrame] inView:controlView];
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
	[super editWithFrame:[self centeredTitleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	if ([self excludeFileExtensionWhenSelecting] && [[[self stringValue] stringByDeletingPathExtension] length] > 0)
		selLength = [[[self stringValue] stringByDeletingPathExtension] length];
	
	[super selectWithFrame:[self centeredTitleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;
	
	[self commonInit];
	
	return self;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	RSVerticallyCenteredTextFieldCell *copy = [super copyWithZone:zone];
	
	copy->_excludeFileExtensionWhenSelecting = _excludeFileExtensionWhenSelecting;
	
	return copy;
}
#pragma mark *** Public Methods ***
- (NSRect)centeredTitleRectForBounds:(NSRect)bounds; {
	NSAttributedString *attributedString = [self attributedStringValue];
	NSSize size = [attributedString size];
	
	return NSCenteredRectWithSize(NSMakeSize(NSWidth(bounds), size.height), bounds);
}

- (void)commonInit; {
	_excludeFileExtensionWhenSelecting = YES;
}
#pragma mark Properties
@synthesize excludeFileExtensionWhenSelecting=_excludeFileExtensionWhenSelecting;
@end
