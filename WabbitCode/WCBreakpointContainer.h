//
//  WCBreakpointContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCFileBreakpoint;

@interface WCBreakpointContainer : RSTreeNode

+ (id)breakpointContainerWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;
- (id)initWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;

@end
