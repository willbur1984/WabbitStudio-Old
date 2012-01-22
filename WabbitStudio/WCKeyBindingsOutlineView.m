//
//  WCKeyBindingsOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingsOutlineView.h"

@implementation WCKeyBindingsOutlineView
#pragma mark *** Subclass Overrides ***
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Filter Results", @"No Filter Results");
}
@end
