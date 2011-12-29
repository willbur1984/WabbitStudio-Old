//
//  RSBorderedGlassGradientView.m
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSBottomBorderedGlassGradientView.h"

@implementation RSBottomBorderedGlassGradientView
- (BOOL)shouldDrawLeftAndRightEdges {
	return YES;
}
- (BOOL)shouldDrawBottomEdge {
	return YES;
}
- (BOOL)shouldDrawTopEdge {
	return NO;
}
@end
