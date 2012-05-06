//
//  RSFindBarFieldEditor.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSFindBarFieldEditor.h"
#import "WCSourceTextView.h"

@implementation RSFindBarFieldEditor
#pragma mark *** Subclass Overrides ***
- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self setFieldEditor:YES];
	
	return self;
}

- (id)supplementalTargetForAction:(SEL)action sender:(id)sender {	
	if ([[self findTextView] respondsToSelector:action])
		return [self findTextView];
	return nil;
}

- (id)performSelector:(SEL)aSelector withObject:(id)object {
	if (aSelector == @selector(performTextFinderAction:) ||
		(![self respondsToSelector:aSelector] && [[self findTextView] respondsToSelector:aSelector]))
		return [[self findTextView] performSelector:aSelector withObject:object];
	return [super performSelector:aSelector withObject:object];
}

#pragma mark NSUserInterfaceValidations
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(performTextFinderAction:) ||
		(![self respondsToSelector:[menuItem action]] && [[self findTextView] respondsToSelector:[menuItem action]]))
		return [[self findTextView] validateMenuItem:menuItem];
	return [super validateMenuItem:menuItem];
}

#pragma mark *** Public Methods ***
+ (RSFindBarFieldEditor *)sharedInstance; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
	});
	return sharedInstance;
}
#pragma mark Properties
@synthesize findTextView=_findTextView;

@end
