//
//  WCJumpInTableView.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpInTableView.h"

@implementation WCJumpInTableView
#pragma mark *** Subclass Overrides ***
- (NSString *)emptyContentString {
	return NSLocalizedString(@"Type a symbol name to jump to", @"Type a symbol name to jump to");
}
@end
