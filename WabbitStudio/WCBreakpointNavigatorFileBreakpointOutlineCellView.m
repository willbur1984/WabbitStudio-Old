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
- (IBAction)breakpointButtonClicked:(id)sender; {
	WCFileBreakpoint *fileBreakpoint = [[self objectValue] representedObject];
	
	[fileBreakpoint setActive:(![fileBreakpoint isActive])];
}
@end
