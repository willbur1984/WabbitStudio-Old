//
//  RSDontSelectPopUpButtonCell.m
//  WabbitStudio
//
//  Created by William Towe on 2/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSDontSelectPopUpButtonCell.h"
#import "RSDontSelectPopUpButton.h"

@implementation RSDontSelectPopUpButtonCell
- (void)selectItem:(NSMenuItem *)item {
	if ([item tag] == RSDontSelectTag)
		return;
	
	[super selectItem:item];
}
@end
