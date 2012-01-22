//
//  WCProjectNavigatorCellView.m
//  WabbitStudio
//
//  Created by William Towe on 1/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectNavigatorCellView.h"
#import "WCProjectNavigatorViewController.h"
#import "WCProject.h"
#import "WCProjectContainer.h"
#import "WCProjectDocument.h"

@implementation WCProjectNavigatorCellView

- (void)controlTextDidBeginEditing:(NSNotification *)note {
	_didBeginEditingNotificationReceived = YES;
}
- (void)controlTextDidEndEditing:(NSNotification *)note {
	if (_didBeginEditingNotificationReceived) {
		_didBeginEditingNotificationReceived = NO;
		
		// post the rename notification
		[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidRenameNodeNotification object:[self projectNavigatorViewController] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[self objectValue],WCProjectNavigatorDidRenameNodeNotificationRenamedNodeUserInfoKey, nil]];
		
		// let the document know there was a change
		[[[[[self projectNavigatorViewController] projectContainer] project] document] updateChangeCount:NSChangeDone];
	}
}

@synthesize projectNavigatorViewController=_projectNavigatorViewController;

@end
