//
//  RSTableView.m
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSTableView.h"
#import "RSDefines.h"


@implementation RSTableView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_emptyContentStringCell release];
    [super dealloc];
}

- (void)keyDown:(NSEvent *)theEvent {
	switch ([theEvent keyCode]) {
		case KEY_CODE_DELETE:
		case KEY_CODE_DELETE_FORWARD:
			if ([[self delegate] respondsToSelector:@selector(handleDeletePressedForTableView:)]) {
				[[self delegate] handleDeletePressedForTableView:self];
				return;
			}
			break;
		case KEY_CODE_RETURN:
		case KEY_CODE_ENTER:
			if ([[self delegate] respondsToSelector:@selector(handleReturnPressedForTableView:)]) {
				[[self delegate] handleReturnPressedForTableView:self];
				return;
			}
			break;
		case KEY_CODE_SPACE:
			if ([[self delegate] respondsToSelector:@selector(handleSpacePressedForTableView:)]) {
				[[self delegate] handleSpacePressedForTableView:self];
				return;
			}
			break;
		case KEY_CODE_TAB:
			if ([[self delegate] respondsToSelector:@selector(handleTabPressedForTableView:)]) {
				[[self delegate] handleTabPressedForTableView:self];
				return;
			}
			break;
		default:
			break;
	}
	[super keyDown:theEvent];
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
	[super drawBackgroundInClipRect:clipRect];
	
	if ([self shouldDrawEmptyContentString]) {
		[_emptyContentStringCell setEmptyContentStringStyle:[self emptyContentStringStyle]];
		[_emptyContentStringCell setStringValue:[self emptyContentString]];
		[_emptyContentStringCell drawWithFrame:[self bounds] inView:self];
	}
}

- (void)drawGridInClipRect:(NSRect)clipRect {
	if (![self shouldDrawEmptyContentString])
		[super drawGridInClipRect:clipRect];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
	if (!(self = [super initWithCoder:decoder]))
		return nil;
	
	_emptyContentStringCell = [[RSEmptyContentCell alloc] initTextCell:@""];
	
	return self;
}
#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
	if ([anItem action] == @selector(delete:))
		return [[self delegate] respondsToSelector:@selector(handleDeletePressedForTableView:)];
	return [super validateUserInterfaceItem:anItem];
}
#pragma mark *** Public Methods ***
- (IBAction)delete:(id)sender; {
	if (![[self delegate] respondsToSelector:@selector(handleDeletePressedForTableView:)]) {
		NSBeep();
		return;
	}
	
	[[self delegate] handleDeletePressedForTableView:self];
}
#pragma mark Properties
@dynamic emptyContentString;
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Content", @"No Content");
}
@dynamic shouldDrawEmptyContentString;
- (BOOL)shouldDrawEmptyContentString {
	return (![self numberOfRows]);
}
@dynamic emptyContentStringStyle;
- (RSEmptyContentStringStyle)emptyContentStringStyle {
	return ([self selectionHighlightStyle] == NSTableViewSelectionHighlightStyleSourceList)?RSEmptyContentStringStyleSourceList:RSEmptyContentStringStyleNormal;
}
@dynamic delegate;
- (id<RSTableViewDelegate>)delegate {
	return (id <RSTableViewDelegate>)[super delegate];
}
- (void)setDelegate:(id<RSTableViewDelegate>)delegate {
	[super setDelegate:delegate];
}

@end
