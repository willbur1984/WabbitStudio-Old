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
	if ([anItem action] == @selector(performTextFinderAction:) ||
		[anItem action] == @selector(jumpToLine:) ||
		[anItem action] == @selector(jumpToDefinition:) ||
		[anItem action] == @selector(jumpInFile:))
		return [[self findTextView] validateUserInterfaceItem:anItem];
	return [super validateUserInterfaceItem:anItem];
}

- (void)performTextFinderAction:(id)sender {
	[[self findTextView] performTextFinderAction:sender];
}

- (IBAction)jumpToLine:(id)sender {
	if ([[self findTextView] respondsToSelector:@selector(jumpToLine:)])
		[(id)[self findTextView] jumpToLine:nil];
}
- (IBAction)jumpToDefinition:(id)sender {
	if ([[self findTextView] respondsToSelector:@selector(jumpToDefinition:)])
		[(id)[self findTextView] jumpToDefinition:nil];
}
- (IBAction)jumpInFile:(id)sender {
	if ([[self findTextView] respondsToSelector:@selector(jumpInFile:)])
		[(id)[self findTextView] jumpInFile:nil];
}

@synthesize findTextView=_findTextView;
@end
