//
//  RSFindBarFieldEditor.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFindBarFieldEditor.h"

@implementation RSFindBarFieldEditor
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
	if ([anItem action] == @selector(performTextFinderAction:))
		return [[self findTextView] validateUserInterfaceItem:anItem];
	return [super validateUserInterfaceItem:anItem];
}

- (void)performTextFinderAction:(id)sender {
	[[self findTextView] performTextFinderAction:sender];
}

@synthesize findTextView=_findTextView;
@end
