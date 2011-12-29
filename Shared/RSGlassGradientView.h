//
//  RSGlassGradientView.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSView.h>

@interface RSGlassGradientView : NSView {
	NSGradient *_fillGradient;
	NSColor *_topFillColor;
	NSColor *_bottomFillColor;
}
@property (readonly,nonatomic) BOOL shouldDrawLeftAndRightEdges;
@property (readonly,nonatomic) BOOL shouldDrawTopEdge;
@property (readonly,nonatomic) BOOL shouldDrawBottomEdge;
@end
