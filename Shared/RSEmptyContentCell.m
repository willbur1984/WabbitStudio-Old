//
//  RSEmptyContentCell.m
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSEmptyContentCell.h"
#import "NSShadow+MCAdditions.h"
#import "NSBezierPath+MCAdditions.h"
#import "RSDefines.h"


@implementation RSEmptyContentCell
#pragma mark *** Subclass Overrides ***
- (id)initTextCell:(NSString *)stringValue {
	if (!(self = [super initTextCell:stringValue]))
		return nil;
	
	[self setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
	[self setAlignment:NSCenterTextAlignment];
	
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	static NSShadow *kDropShadow = nil;
	static NSShadow *kInnerShadow = nil;
	if (!kDropShadow) {
		kDropShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] offset:NSMakeSize(0, -1.0) blurRadius:1.0];
		kInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:141.0/255.0 alpha:1.0] offset:NSMakeSize(0.0, -1.0) blurRadius:1.0];
	}
	
	NSSize textSize = [self cellSizeForBounds:cellFrame];
	NSRect backgroundRect = NSCenteredRectWithSize(NSMakeSize(textSize.width+12.0, textSize.height+8.0), cellFrame);
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:5.0 yRadius:5.0];
	
	if ([self emptyContentStringStyle] == RSEmptyContentStringStyleSourceList) {
		// draw our shadow first
		[NSGraphicsContext saveGraphicsState];
		[kDropShadow set];
		
		// use the same color as Xcode for now
		
		[[NSColor colorWithCalibratedWhite:151.0/255.0 alpha:1.0] setFill];
		[path fill];
		[NSGraphicsContext restoreGraphicsState];
		
		[path fillWithInnerShadow:kInnerShadow];
	}
	else {
		[[NSColor colorWithCalibratedWhite:0.592 alpha:1.0] setFill];
		[path fill];
	}
	
	if ([self emptyContentStringStyle] == RSEmptyContentStringStyleSourceList)
		[self setBackgroundStyle:NSBackgroundStyleLowered];
	else
		[self setBackgroundStyle:NSBackgroundStyleDark];
	
	[super drawInteriorWithFrame:NSCenteredRectWithSize(textSize, backgroundRect) inView:controlView];
}
#pragma mark Properties
@synthesize emptyContentStringStyle=_emptyContentStringStyle;
@end
