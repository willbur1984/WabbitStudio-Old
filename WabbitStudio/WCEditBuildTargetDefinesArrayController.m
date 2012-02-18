//
//  WCEditBuildTargetDefinesArrayController.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetDefinesArrayController.h"

@implementation WCEditBuildTargetDefinesArrayController
#pragma mark *** Subclass Overrides ***
- (void)awakeFromNib {
	//[oTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
	[oTableView registerForDraggedTypes:[NSArray arrayWithObjects:kRSRTVMovedRowsType, nil]];
	[self setDraggingEnabled:YES];
	[self setShouldAllowDragCopy:NO];
}
@end
