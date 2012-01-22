//
//  WCTabView.m
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTabView.h"

@implementation WCTabView
#pragma mark *** Subclass Overrides ***
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Open Files", @"No Open Files");
}
@end
