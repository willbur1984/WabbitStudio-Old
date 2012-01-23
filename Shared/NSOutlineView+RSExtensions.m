//
//  NSOutlineView+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 7/21/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

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
