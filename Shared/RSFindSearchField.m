//
//  RSFindSearchField.m
//  WabbitEdit
//
//  Created by William Towe on 12/30/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSFindSearchField.h"
#import "RSFindBarViewController.h"
#import "NSEvent+RSExtensions.h"

@implementation RSFindSearchField
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"G"] &&
		[theEvent isOnlyCommandKeyPressed]) {
		// Shift + Command + g is 'Find Previous'
		[[self findBarViewController] findPrevious:nil];	
		return YES;
	}
	else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"g"] &&
			 [theEvent isOnlyCommandKeyPressed]) {
		// Command + g is 'Find Next'
		[[self findBarViewController] findNext:nil];
		return YES;
	}
	return [super performKeyEquivalent:theEvent];
}

@synthesize findBarViewController=_findBarViewController;
@end
