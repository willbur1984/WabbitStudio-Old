//
//  WCBreakpointNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBreakpointNavigatorOutlineView.h"

@implementation WCBreakpointNavigatorOutlineView
#pragma mark *** Subclass Overrides ***
+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Edit Breakpoint", @"Edit Breakpoint") action:@selector(editBreakpoint:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Disable Breakpoint", @"Disable Breakpoint") action:@selector(toggleBreakpoint:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete Breakpoint", @"Delete Breakpoint") action:@selector(deleteBreakpoint:) keyEquivalent:@""];
	});
	return retval;
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Breakpoints", @"No Breakpoints");
}
- (BOOL)shouldDrawEmptyContentString {
	if ([self numberOfRows] == 1) {
		if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
			return (![[[self itemAtRow:0] childNodes] count]);
		}
		else {
			return (![[self dataSource] outlineView:self numberOfChildrenOfItem:[self itemAtRow:0]]);
		}
	}
	else if (![self numberOfRows])
		return YES;
	return NO;
}
@end
