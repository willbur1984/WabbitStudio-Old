//
//  RSVerticallyCenteredTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 4/21/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

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
