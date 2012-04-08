//
//  WCEditBuildTargetDefinesTableView.m
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetDefinesTableView.h"

@implementation WCEditBuildTargetDefinesTableView
#pragma mark *** Subclass Overrides ***
- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
	if (context == NSDraggingContextWithinApplication)
		return NSDragOperationMove;
	return NSDragOperationCopy;
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session {
	return YES;
}

- (BOOL)verticalMotionCanBeginDrag {
	return YES;
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Defines", @"No Defines");
}
@end
