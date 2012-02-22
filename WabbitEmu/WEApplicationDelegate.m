//
//  WEApplicationDelegate.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEApplicationDelegate.h"

@implementation WEApplicationDelegate
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}
@end
