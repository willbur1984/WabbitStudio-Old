//
//  WCBreakpointNavigatorFileBreakpointOutlineCellView.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointNavigatorFileBreakpointOutlineCellView.h"
#import "WCFileBreakpoint.h"

@implementation WCBreakpointNavigatorFileBreakpointOutlineCellView
#pragma mark *** Public Methods ***

#pragma mark IBActions
- (IBAction)breakpointButtonClicked:(id)sender; {
	WCFileBreakpoint *fileBreakpoint = [[self objectValue] representedObject];
	
	[fileBreakpoint setActive:(![fileBreakpoint isActive])];
}
#pragma mark Properties
@synthesize breakpointButton=_breakpointButton;

@end
