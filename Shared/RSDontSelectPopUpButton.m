//
//  RSDontSelectPopUpButton.m
//  WabbitStudio
//
//  Created by William Towe on 2/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSDontSelectPopUpButton.h"

@implementation RSDontSelectPopUpButton

- (void)selectItem:(NSMenuItem *)item {
	if ([item tag] == RSDontSelectTag)
		return;
	
	[super selectItem:item];
}

@end
