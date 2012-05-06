//
//  NSOutlineView+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 7/21/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSOutlineView+RSExtensions.h"
#import "NSArray+WCExtensions.h"
#import "NSTreeController+RSExtensions.h"

@implementation NSOutlineView (NSOutlineView_RSExtensions)
- (NSIndexSet *)rowsForItems:(NSArray *)items; {
	NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
	
	for (id item in items) {
		NSInteger rowIndex = [self rowForItem:item];
		if (rowIndex == -1)
			continue;
		[rowIndexes addIndex:rowIndex];
	}
	return rowIndexes;
}

- (id)selectedItem; {
	return [[self selectedItems] firstObject];
}
- (NSArray *)selectedItems; {
	if ([[self dataSource] isKindOfClass:[NSTreeController class]])
		return [[(NSTreeController *)[self dataSource] selectedNodes] valueForKey:@"representedObject"];
	
	NSIndexSet *selectedIndexes = [self selectedRowIndexes];
	NSMutableArray *selectedItems = [NSMutableArray arrayWithCapacity:[selectedIndexes count]];
	
	[selectedIndexes enumerateIndexesWithOptions:0 usingBlock:^(NSUInteger idx, BOOL *stop) {
		id item = [self itemAtRow:idx];
		if (!item)
			return;
		
		[selectedItems addObject:item];
	}];
	return selectedItems;
}

- (NSArray *)expandedItems; {
	NSMutableArray *retval = [NSMutableArray array];
	if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
		NSUInteger rowIndex, numberOfRows = [self numberOfRows];
		for (rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
			id item = [self itemAtRow:rowIndex];
			if ([self isItemExpanded:item])
				[retval addObject:[item representedObject]];
		}
	}
	else {
		NSUInteger rowIndex, numberOfRows = [self numberOfRows];
		for (rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
			id item = [self itemAtRow:rowIndex];
			if ([self isItemExpanded:item])
				[retval addObject:item];
		}
	}
	return retval;
}

- (void)expandItems:(NSArray *)items; {
	if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
		// items are expected to be model objects, not NSTreeNode objects
		for (id item in items) {
			NSTreeNode *node = [(NSTreeController *)[self dataSource] treeNodeForRepresentedObject:item];
			
			[self expandItem:node];
		}
	}
	else {
		for (id item in items)
			[self expandItem:item];
	}
}

- (NSArray *)expandedModelObjects; {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	NSUInteger rowIndex, numberOfRows = [self numberOfRows];
	
	if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
		for (rowIndex=0; rowIndex<numberOfRows; rowIndex++) {
			id item = [self itemAtRow:rowIndex];
			
			if ([self isItemExpanded:item])
				[retval addObject:[[item representedObject] representedObject]];
		}
	}
	else {
		for (rowIndex=0; rowIndex<numberOfRows; rowIndex++) {
			id item = [self itemAtRow:rowIndex];
			
			if ([self isItemExpanded:item])
				[retval addObject:[item representedObject]];
		}
	}
	
	return [[retval copy] autorelease];
}
- (void)expandModelObjects:(NSArray *)modelObjects; {
	if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
		for (NSTreeNode *treeNode in [(NSTreeController *)[self dataSource] treeNodesForModelObjects:modelObjects])
			[self expandItem:treeNode];
	}
	else {
		// TODO: implement expansion of model objects without an NSTreeController populating the outline view
	}
}

- (NSArray *)rootItems; {
	NSMutableArray *retval = [NSMutableArray array];
	NSUInteger rowIndex, numberOfRows = [self numberOfRows];
	
	if ([[self dataSource] isKindOfClass:[NSTreeController class]])
		return [(NSTreeController *)[self dataSource] rootNodes];
	else {
		for (rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
			id item = [self itemAtRow:rowIndex];
			if (![self parentForItem:item])
				[retval addObject:item];
		}
	}
	return retval;
}
@end
