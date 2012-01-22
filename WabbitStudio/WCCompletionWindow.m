//
//  WCCompletionWindow.m
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCCompletionWindow.h"

@implementation WCCompletionWindow
#pragma mark *** Subclass Overrides ***
// so our table view will draw with the correct gradient highlight
- (BOOL)isKeyWindow {
	return YES;
}
@end
