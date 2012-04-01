//
//  RSFindBarFieldEditor.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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

#pragma mark IBActions
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
