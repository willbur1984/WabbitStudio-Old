//
//  WCProjectNavigatorTreeController.m
//  WabbitStudio
//
//  Created by William Towe on 1/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectNavigatorTreeController.h"
#import "NSTreeController+RSExtensions.h"
#import "NSTreeNode+RSExtensions.h"
#import "NSAlert-OAExtensions.h"
#import "RSDefines.h"
#import "WCProjectNavigatorViewController.h"
#import "WCProjectDocument.h"
#import "WCFile.h"
#import "RSTreeNode.h"

@interface WCProjectNavigatorTreeController ()

@end

@implementation WCProjectNavigatorTreeController
- (void)dealloc {
	[super dealloc];
}

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {

	return [[item representedObject] representedObject];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
	// don't allows drops on the root or on a particular item
	if (!item || index == NSOutlineViewDropOnItemIndex)
		return NSDragOperationNone;
	else if ([info draggingSource] == outlineView) {
		item = [item representedObject];
		
		// grab all the pasteboard items
		NSArray *pboardItems = [[info draggingPasteboard] pasteboardItems];
		// grab the project document's mapping of uuids to files
		NSDictionary *UUIDsToFiles = [[[self projectNavigatorViewController] projectDocument] UUIDsToFiles];
		// array to hold our corresponding files
		NSMutableArray *files = [NSMutableArray arrayWithCapacity:[pboardItems count]];
		
		// map each uuid to its corresponding file
		for (NSPasteboardItem *pboardItem in pboardItems) {
			NSString *UUID = [pboardItem stringForType:WCPasteboardTypeFileUUID];
			WCFile *file = [UUIDsToFiles objectForKey:UUID];
			
#ifdef DEBUG
			// something is really borked if there isn't a corresponding file for each uuid at this point
			NSAssert(file, @"file cannot be nil!");
#endif
			
			[files addObject:file];
		}
		
		// grab the corresponding RSTreeNode objects for each file in the files array
		for (RSTreeNode *node in [self representedObjectsForModelObjects:files]) {
			// cannot drag an item to itself
			if (node == item)
				return NSDragOperationNone;
			// cannot drag an item to a group that is a descendant of the item being dragged
			else if ([(RSTreeNode *)item isDescendantOfNode:node])
				return NSDragOperationNone;
			// if we are dragging a single item with its parent, require the item to move up or down at least one index
			else if ([pboardItems count] == 1 &&
					 item == [node parentNode] &&
					 ([[[node parentNode] childNodes] indexOfObjectIdenticalTo:node] == index ||
					  [[[node parentNode] childNodes] indexOfObjectIdenticalTo:node] == --index))
				return NSDragOperationNone;
		}
		return NSDragOperationMove;
	}
	return NSDragOperationCopy;
}

- (void)outlineView:(NSOutlineView *)outlineView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
	// create a new NSTableCellView from out outline table view (which is the column that contains the disclosure arrow)
	NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"MainCell" owner:nil];
	// initial frame of the cell view, origin doesn't matter, but use the same size as the outline view
	__block NSRect cellFrame = NSMakeRect(0.0, 0.0, [[outlineView outlineTableColumn] width], [outlineView rowHeight]);
	
	// adjust the width with respect to our intercell spacing, the height is not affected
	cellFrame.size.width -= [outlineView intercellSpacing].width;
	
	__block NSInteger numberOfValidDraggingItems = 0;
	NSDictionary *UUIDsToObjects = [[[self projectNavigatorViewController] projectDocument] UUIDsToFiles];
	
	[draggingInfo enumerateDraggingItemsWithOptions:0 forView:outlineView classes:[NSArray arrayWithObjects:/*[NSString class],*/[NSURL class], nil] searchOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey, nil] usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
		
		// set our initial dragging frame from above
		[draggingItem setDraggingFrame:cellFrame];
		
		id item = [draggingItem item];
		
		if ([item isKindOfClass:[NSString class]]) {
			WCFile *file = [UUIDsToObjects objectForKey:item];
			
			if (file) {
				[draggingItem setImageComponentsProvider:^(void) {
					// object value for the cell view is our model object (instance of WCFile in this case)
					[cellView setObjectValue:[RSTreeNode treeNodeWithRepresentedObject:file]];
					// use the same frame from above
					[cellView setFrame:cellFrame];
					
					// the cell view will provide the components for us
					return [cellView draggingImageComponents];
				}];
				
				// adjust the y position of the frame for the next dragging item
				cellFrame.origin.y += NSHeight(cellFrame);
				numberOfValidDraggingItems++;
			}
			else
				[draggingItem setImageComponentsProvider:nil];
		}
		else if ([item isKindOfClass:[NSURL class]]) {
			[draggingItem setImageComponentsProvider:^(void) {
				// object value for the cell view is our model object (instance of WCFile in this case)
				[cellView setObjectValue:[RSTreeNode treeNodeWithRepresentedObject:item]];
				// use the same frame from above
				[cellView setFrame:cellFrame];
				
				// the cell view will provide the components for us
				return [cellView draggingImageComponents];
			}];
			
			// adjust the y position of the frame for the next dragging item
			cellFrame.origin.y += NSHeight(cellFrame);
			numberOfValidDraggingItems++;
		}
	}];
	
	// let the dragging info know how many items we can accept, this updates the badge count correctly
	[draggingInfo setNumberOfValidItemsForDrop:numberOfValidDraggingItems];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
	if ([info draggingSource] == outlineView) {
		// grab all the pasteboard items
		NSArray *pboardItems = [[info draggingPasteboard] pasteboardItems];
		// grab the project document's mapping of uuids to files
		NSDictionary *UUIDsToFiles = [[[self projectNavigatorViewController] projectDocument] UUIDsToFiles];
		// temp array to hold our files
		NSMutableArray *files = [NSMutableArray arrayWithCapacity:[pboardItems count]];
		
		// map each uuid to its corresponding file
		for (NSPasteboardItem *pboardItem in pboardItems) {
			NSString *UUID = [pboardItem stringForType:WCPasteboardTypeFileUUID];
			WCFile *file = [UUIDsToFiles objectForKey:UUID];
			
#ifdef DEBUG
			NSAssert(file, @"file cannot be nil!");
#endif
			
			[files addObject:file];
		}
		
		// grab the corresponding NSTreeNode objects for our files
		NSArray *nodes = [self treeNodesForModelObjects:files];
		
		// move the nodes to wherever they need to be
		[self moveNodes:nodes toIndexPath:[[item indexPath] indexPathByAddingIndex:index]];
		
		// the set of moved RSTreeNode objects is the union of all the leaf node arrays
		NSSet *movedFileContainers = [NSSet setWithArray:[nodes valueForKeyPath:@"representedObject.@unionOfArrays.descendantLeafNodesInclusive"]];
		
		// post the appropriate notification
		[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidMoveNodesNotification object:[self projectNavigatorViewController] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:movedFileContainers,WCProjectNavigatorDidMoveNodesNotificationMovedNodesUserInfoKey, nil]];
		
		// let the project document know there was a change
		[[[self projectNavigatorViewController] projectDocument] updateChangeCount:NSChangeDone];
	}
	return YES;
}

@synthesize projectNavigatorViewController=_projectNavigatorViewController;

@end
