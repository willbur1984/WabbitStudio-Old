//
//  WCApplication.m
//  WabbitStudio
//
//  Created by William Towe on 3/9/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCApplication.h"

@interface WCApplication ()
- (void)_updateWindowsMenu;
@end

@implementation WCApplication
- (void)addWindowsItem:(NSWindow *)win title:(NSString *)aString filename:(BOOL)isFilename {
	[super addWindowsItem:win title:aString filename:isFilename];
	
	[self _updateWindowsMenu];
}

- (void)changeWindowsItem:(NSWindow *)win title:(NSString *)aString filename:(BOOL)isFilename {
	[super changeWindowsItem:win title:aString filename:isFilename];
	
	[self _updateWindowsMenu];
}

- (void)_updateWindowsMenu; {
	
}
@end
