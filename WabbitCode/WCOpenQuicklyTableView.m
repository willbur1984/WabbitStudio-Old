//
//  WCOpenQuicklyTableView.m
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCOpenQuicklyTableView.h"

@implementation WCOpenQuicklyTableView
#pragma mark *** Subclass Overrides ***
- (NSString *)emptyContentString {
	return NSLocalizedString(@"Type a file or symbol name to open", @"Type a file or symbol name to open");
}
@end
