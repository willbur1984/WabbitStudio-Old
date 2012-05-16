//
//  RSCollectionView.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSCollectionView.h"
#import "RSDefines.h"

@implementation RSCollectionView

#pragma mark *** Subclass Overrides ***
- (void)keyDown:(NSEvent *)theEvent {
	switch ([theEvent keyCode]) {
		case KEY_CODE_RETURN:
		case KEY_CODE_ENTER:
			if ([[self delegate] respondsToSelector:@selector(handleReturnPressedForCollectionView:)]) {
				[[self delegate] handleReturnPressedForCollectionView:self];
				return;
			}
			break;
		case KEY_CODE_TAB:
			if ([[self delegate] respondsToSelector:@selector(handleTabPressedForCollectionView:)]) {
				[[self delegate] handleTabPressedForCollectionView:self];
				return;
			}
			break;
		default:
			break;
	}
	[super keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
	if ([theEvent type] == NSLeftMouseDown &&
		[theEvent clickCount] == 2) {
		
		if ([[self delegate] respondsToSelector:@selector(collectionView:handleDoubleClickForItemsAtIndexes:)]) {
			[[self delegate] collectionView:self handleDoubleClickForItemsAtIndexes:[self selectionIndexes]];
			return;
		}
	}
    else if ([theEvent type] == NSLeftMouseDown &&
             [theEvent clickCount] == 1) {
        
        if ([[self delegate] respondsToSelector:@selector(collectionView:handleSingleClickForItemsAtIndexes:)]) {
            [[self delegate] collectionView:self handleSingleClickForItemsAtIndexes:[self selectionIndexes]];
            return;
        }
    }
	[super mouseDown:theEvent];
}

- (void)setSelectionIndexes:(NSIndexSet *)indexes; {
    if (self.allowsEmptySelection)
        [super setSelectionIndexes:indexes];
    else if (!indexes.count && !self.allowsEmptySelection)
        return;
    
	[super setSelectionIndexes:indexes];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
@dynamic delegate;
- (id<RSCollectionViewDelegate>)delegate {
	return (id<RSCollectionViewDelegate>)[super delegate];
}
- (void)setDelegate:(id<RSCollectionViewDelegate>)delegate {
	[super setDelegate:delegate];
}

@synthesize allowsEmptySelection=_allowsEmptySelection;

@end
