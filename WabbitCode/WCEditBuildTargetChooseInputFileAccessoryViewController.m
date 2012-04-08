//
//  WCEditBuildTargetChooseInputFileAccessoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetChooseInputFileAccessoryViewController.h"

@implementation WCEditBuildTargetChooseInputFileAccessoryViewController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	
	return self;
}

- (NSString *)nibName {
	return @"WCEditBuildTargetChooseInputFileAccessoryView";
}

@end
