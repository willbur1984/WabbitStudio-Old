//
//  RSFindBarFieldEditor.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFindBarFieldEditor.h"

@implementation RSFindBarFieldEditor
#pragma mark *** Subclass Overrides ***
- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self setFieldEditor:YES];
	
	return self;
}
#pragma mark IBActions
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

#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
	if ([anItem action] == @selector(performTextFinderAction:) ||
		[anItem action] == @selector(jumpToLine:) ||
		[anItem action] == @selector(jumpToDefinition:) ||
		[anItem action] == @selector(jumpInFile:))
		return [[self findTextView] validateUserInterfaceItem:anItem];
	return [super validateUserInterfaceItem:anItem];
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
