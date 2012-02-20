//
//  RSCollectionView.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
	[super mouseDown:theEvent];
}

- (void)setSelectionIndexes:(NSIndexSet *)indexes; {
	// don't allow empty selection
	if (![indexes count])
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

@end
