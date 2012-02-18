//
//  WCEditBuildTargetIncludesArrayController.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetIncludesArrayController.h"
#import "WCBuildTarget.h"
#import "WCBuildInclude.h"
#import "WCEditBuildTargetWindowController.h"

@implementation WCEditBuildTargetIncludesArrayController
#pragma mark *** Subclass Overrides ***
- (void)awakeFromNib {
	//[oTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
	[oTableView registerForDraggedTypes:[NSArray arrayWithObjects:kRSRTVMovedRowsType,kUTTypeFileURL, nil]];
	[self setDraggingEnabled:YES];
	[self setShouldAllowDragCopy:NO];
}
#pragma mark NSTableViewDataSource
- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id<NSDraggingInfo>)info {
	[info setDraggingFormation:NSDraggingFormationList];
	if ([info draggingSource] == tableView)
		return;
	
	NSTableColumn *tableColumn = [[tableView tableColumns] objectAtIndex:0];
	// create a new NSTableCellView from out outline table view (which is the column that contains the disclosure arrow)
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
	// initial frame of the cell view, origin doesn't matter, but use the same size as the outline view
	__block NSRect cellFrame = NSMakeRect(0.0, 0.0, [tableColumn width], [tableView rowHeight]);
	
	// adjust the width with respect to our intercell spacing, the height is not affected
	cellFrame.size.width -= [tableView intercellSpacing].width;
	
	// grab the set of all file paths in the project
	WCBuildTarget *target = [[self editBuildTargetWindowController] buildTarget];
	NSSet *filePaths = [NSSet setWithArray:[[target includes] valueForKey:@"path"]];
	__block NSInteger numberOfValidDraggingItems = 0;
	
	[info enumerateDraggingItemsWithOptions:0 forView:tableView classes:[NSArray arrayWithObject:[WCBuildInclude class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
		
		// if the dragging item's file path isn't already in the project, then we can accept it
		if (![filePaths containsObject:[(WCBuildInclude *)[draggingItem item] path]]) {
			// set our initial dragging frame from above
			[draggingItem setDraggingFrame:cellFrame];
			
			[draggingItem setImageComponentsProvider:^(void) {
				// object value for the cell view is our model object (instance of WCFile in this case)
				[cellView setObjectValue:[draggingItem item]];
				// use the same frame from above
				[cellView setFrame:cellFrame];
				
				// since our image view and text field are hooked up to the appropriate outlets, the cell view will provide the components for us
				return [cellView draggingImageComponents];
			}];
			
			// adjust the y position of the frame for the next dragging item
			cellFrame.origin.y += NSHeight(cellFrame);
			numberOfValidDraggingItems++;
		}
		// the dragging item's file path was already in the project
		else {
			[draggingItem setImageComponentsProvider:nil];
		}
	}];
	
	// let the dragging info know how many items we can accept, this updates the badge count correctly
	[info setNumberOfValidItemsForDrop:numberOfValidDraggingItems];
}

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
	if ([info draggingSource] != tv) {
		[tv setDropRow:-1 dropOperation:NSTableViewDropOn];
		
		WCBuildTarget *target = [[self editBuildTargetWindowController] buildTarget];
		NSSet *includePaths = [NSSet setWithArray:[[target includes] valueForKey:@"path"]];
		NSInteger numberOfValidDraggingItems = 0;
		
		for (NSPasteboardItem *pboardItem in [[info draggingPasteboard] pasteboardItems]) {
			// create a file URL from the string representation of the URL represented by the pasteboard item
			NSURL *fileURL = [NSURL URLWithString:[pboardItem propertyListForType:(NSString *)kUTTypeFileURL]];
			
			// if the file path is already in our project, skip it
			if ([includePaths containsObject:[fileURL path]])
				continue;
			
			NSNumber *isDirectory;
			if (![fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] ||
				![isDirectory boolValue])
				continue;
			
			numberOfValidDraggingItems++;
		}
		return (numberOfValidDraggingItems)?NSDragOperationCopy:NSDragOperationNone;
	}
	return [super tableView:tv validateDrop:info proposedRow:row proposedDropOperation:op];
}

- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op {
	if ([info draggingSource] != tv) {
		WCBuildTarget *target = [[self editBuildTargetWindowController] buildTarget];
		NSSet *includePaths = [NSSet setWithArray:[[target includes] valueForKey:@"path"]];
		NSMutableArray *includes = [NSMutableArray array];
		
		for (NSPasteboardItem *pboardItem in [[info draggingPasteboard] pasteboardItems]) {
			// create a file URL from the string representation of the URL represented by the pasteboard item
			NSURL *fileURL = [NSURL URLWithString:[pboardItem propertyListForType:(NSString *)kUTTypeFileURL]];
			
			// if the file path is already in our project, skip it
			if ([includePaths containsObject:[fileURL path]])
				continue;
			
			NSNumber *isDirectory;
			if (![fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] ||
				![isDirectory boolValue])
				continue;
			
			[includes addObject:[WCBuildInclude buildIncludeWithDirectoryURL:fileURL]];
		}
		
		[self addObjects:includes];
		
		return YES;
	}
	return [super tableView:tv acceptDrop:info row:row dropOperation:op];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
@synthesize editBuildTargetWindowController=_editBuildTargetWindowController;
@end
