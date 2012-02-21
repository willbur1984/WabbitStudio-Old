//
//  WCJumpInCellView.m
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpInCellView.h"

@implementation WCJumpInCellView
#pragma mark *** Subclass Overrides ***
- (NSView *)hitTest:(NSPoint)aPoint {
	return self;
}
@end
