//
//  WCProjectNavigatorCellView.m
//  WabbitStudio
//
//  Created by William Towe on 1/21/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectNavigatorCellView.h"
#import "WCProjectNavigatorViewController.h"
#import "WCProject.h"
#import "WCProjectContainer.h"
#import "WCProjectDocument.h"

@implementation WCProjectNavigatorCellView
#pragma mark *** Subclass Overrides ***

#pragma mark NSControlTextEditingDelegate
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
#pragma mark *** Public Methods ***

#pragma mark Properties
@synthesize projectNavigatorViewController=_projectNavigatorViewController;

@end
