//
//  RSTopBorderedGlassGradientView.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTopBorderedGlassGradientView.h"

@implementation RSTopBorderedGlassGradientView
- (BOOL)shouldDrawBottomEdge {
	return NO;
}
- (BOOL)shouldDrawTopEdge {
	return YES;
}
- (BOOL)shouldDrawLeftEdge {
	return NO;
}
- (BOOL)shouldDrawRightEdge {
	return NO;
}
@end
