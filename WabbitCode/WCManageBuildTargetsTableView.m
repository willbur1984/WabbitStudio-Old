//
//  WCManageBuildTargetsTableView.m
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCManageBuildTargetsTableView.h"

@implementation WCManageBuildTargetsTableView
#pragma mark *** Subclass Overrides ***
+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"New Build Target", @"New Build Target") action:@selector(newBuildTarget:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"New Build Target from Template", @"New Build Target from Template") action:@selector(newBuildTargetFromTemplate:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete Build Target", @"Delete Build Target") action:@selector(deleteBuildTarget:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Duplicate Build Target", @"Duplicate Build Target") action:@selector(duplicateBuildTarget:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Rename Build Target", @"Rename Build Target") action:@selector(renameBuildTarget:) keyEquivalent:@""];
	});
	return retval;
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Build Targets", @"No Build Targets");
}
@end
