//
//  RSFindTextField.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFindTextField.h"
#import "RSFindTextFieldCell.h"

@implementation RSFindTextField
+ (Class)cellClass {
	return [RSFindTextFieldCell class];
}

@synthesize findBarViewController=_findBarViewController;
@end
