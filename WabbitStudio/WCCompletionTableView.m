//
//  WCCompletionTableView.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCCompletionTableView.h"

@implementation WCCompletionTableView
#pragma mark *** Subclass Overrides ***
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Completions", @"No Completions");
}
@end
