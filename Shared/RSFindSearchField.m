//
//  RSFindSearchField.m
//  WabbitEdit
//
//  Created by William Towe on 12/30/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSFindSearchField.h"
#import "RSFindSearchFieldCell.h"

@implementation RSFindSearchField
#pragma mark *** Subclass Overrides ***
+ (Class)cellClass {
	return [RSFindSearchFieldCell class];
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@synthesize findBarViewController=_findBarViewController;
@end
