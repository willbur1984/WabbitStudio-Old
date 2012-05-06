//
//  RSTableView.m
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
