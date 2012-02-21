//
//  WCRoundedBorderImageCell.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCRoundedBorderImageCell.h"
#import "WCRoundedBorderImageView.h"
#import "RSDefines.h"
#import "NSBezierPath+StrokeExtensions.h"

@implementation WCRoundedBorderImageCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	WCRoundedBorderImageView *imageView = (WCRoundedBorderImageView *)controlView;
	
	if ([[imageView collectionViewItem] isSelected]) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:5.0 yRadius:5.0];
		
		if ([[controlView window] isKeyWindow] && [[[controlView window] firstResponder] isKindOfClass:[NSCollectionView class]]) {
			[[[NSColor alternateSelectedControlColor] colorWithAlphaComponent:0.35] setFill];
			[path fill];
			[[NSColor alternateSelectedControlColor] setStroke];
			[path strokeInside];
		}
		else {
			[[[NSColor secondarySelectedControlColor] colorWithAlphaComponent:0.35] setFill];
			[path fill];
			[[NSColor secondarySelectedControlColor] setStroke];
			[path strokeInside];
		}
	}
	
	[self drawInteriorWithFrame:NSCenteredRectWithSize(NSMakeSize(48.0, 48.0), cellFrame) inView:controlView];
}
@end
