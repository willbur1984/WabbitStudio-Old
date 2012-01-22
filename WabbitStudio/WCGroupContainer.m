//
//  WCGroupContainer.m
//  WabbitStudio
//
//  Created by William Towe on 1/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCGroupContainer.h"

@implementation WCGroupContainer
#pragma mark *** Subclass Overrides ***
- (BOOL)isLeafNode {
	return NO;
}

@dynamic group;
- (WCGroup *)group {
	return (WCGroup *)[self representedObject];
}
@end
