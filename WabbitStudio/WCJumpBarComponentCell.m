//
//  WCJumpBarComponentCell.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCJumpBarComponentCell.h"
#import "RSDefines.h"
#import "RSVerticallyCenteredTextFieldCell.h"

@interface WCJumpBarComponentCell ()
@property (readonly,nonatomic) BOOL isLastPathComponentCell;

- (void)_commonInit;
@end

@implementation WCJumpBarComponentCell
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_titleCell release];
	[super dealloc];
}

- (id)initTextCell:(NSString *)aString {
	if (!(self = [super initTextCell:aString]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (NSRect)imageRectForBounds:(NSRect)theRect {
	if (![self image])
		return NSZeroRect;
	
	static const CGFloat kImageMarginLeft = 2.0;
	
	return NSCenteredRectWithSize(NSSmallSize, NSMakeRect(NSMinX(theRect)+kImageMarginLeft, NSMinY(theRect), NSSmallSize.width, NSHeight(theRect)));
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSRect imageRect = [self imageRectForBounds:cellFrame];
	
	if ([self image])
		[[self image] drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];

	static const CGFloat kArrowSeparatorMarginRight = 2.0;
	
	NSImage *arrowSeparator = [NSImage imageNamed:@"ArrowSeparator"];
	
	if (!NSIsEmptyRect([self titleRectForBounds:cellFrame])) {
		static const CGFloat kTitleMarginLeft = 1.0;
		static const CGFloat kSymbolTitleMarginLeft = 2.0;
		
		[_titleCell setStringValue:[self stringValue]];
		
		if ([self image] && [self isLastPathComponentCell])
			[_titleCell drawWithFrame:NSMakeRect(NSMaxX(imageRect)+kSymbolTitleMarginLeft, NSMinY(cellFrame), NSWidth(cellFrame)-NSWidth(imageRect)-kSymbolTitleMarginLeft, NSHeight(cellFrame)) inView:controlView];
		else if ([self image])
			[_titleCell drawWithFrame:NSMakeRect(NSMaxX(imageRect)+kTitleMarginLeft, NSMinY(cellFrame), NSWidth(cellFrame)-NSWidth(imageRect)-[arrowSeparator size].width-kArrowSeparatorMarginRight, NSHeight(cellFrame)) inView:controlView];
		else if ([self isLastPathComponentCell])
			[_titleCell drawWithFrame:NSMakeRect(NSMinX(cellFrame)+kTitleMarginLeft, NSMinY(cellFrame), NSWidth(cellFrame)-kTitleMarginLeft, NSHeight(cellFrame)) inView:controlView];
		else
			[_titleCell drawWithFrame:NSMakeRect(NSMinX(cellFrame)+kTitleMarginLeft, NSMinY(cellFrame), NSWidth(cellFrame)-kTitleMarginLeft-[arrowSeparator size].width-kArrowSeparatorMarginRight, NSHeight(cellFrame)) inView:controlView];
	}
	
	if (![self isLastPathComponentCell])
		[arrowSeparator drawInRect:NSCenteredRectWithSize([arrowSeparator size], NSMakeRect(NSMaxX(cellFrame)-[arrowSeparator size].width-kArrowSeparatorMarginRight, NSMinY(cellFrame), [arrowSeparator size].width, NSHeight(cellFrame))) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCJumpBarComponentCell *copy = [super copyWithZone:zone];
	
	copy->_titleCell = [_titleCell copyWithZone:zone];
	
	return copy;
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@dynamic isLastPathComponentCell;
- (BOOL)isLastPathComponentCell {
	return ([[(NSPathControl *)[self controlView] pathComponentCells] lastObject] == self);
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	[self setBackgroundStyle:NSBackgroundStyleRaised];
	[self setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	
	_titleCell = [[RSVerticallyCenteredTextFieldCell alloc] initTextCell:@""];
	[_titleCell setBackgroundStyle:NSBackgroundStyleRaised];
	[_titleCell setControlSize:NSSmallControlSize];
	[_titleCell setFont:[self font]];
}
@end
