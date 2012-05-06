//
//  WCProjectNavigatorOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectNavigatorOutlineView.h"
#import "WCFile.h"

@implementation WCProjectNavigatorOutlineView
#pragma mark *** Subclass Overrides ***
+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Show in Finder", @"Show in Finder") action:@selector(showInFinder:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Open with External Editor", @"Open with External Editor") action:@selector(openWithExternalEditor:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"New Group", @"New Group") action:@selector(newGroup:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"New Group from Selection", @"New Group from Selection") action:@selector(newGroupFromSelection:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Ungroup Selection", @"Ungroup Selection") action:@selector(ungroupSelection:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Add Files to Project\u2026", @"Add Files to Project with ellipsis") action:@selector(addFilesToProject:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Delete\u2026", @"Delete with ellipsis") action:@selector(delete:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Rename", @"Rename") action:@selector(rename:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Open in Separate Editor", @"Open in Separate Editor") action:@selector(openInSeparateEditor:) keyEquivalent:@""];
	});
	return retval;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:WCPasteboardTypeFileUUID,kUTTypeFileURL,kUTTypeDirectory, nil]];
}

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
- (BOOL)canDragRowsWithIndexes:(NSIndexSet *)rowIndexes atPoint:(NSPoint)mouseDownPoint {
	if ([rowIndexes containsIndex:0])
		return NO;
	return YES;
}

- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Filter Results", @"No Filter Results");
}
- (BOOL)shouldDrawEmptyContentString {
	if ([self numberOfRows] == 1) {
		if ([[self dataSource] isKindOfClass:[NSTreeController class]]) {
			return (![[[self itemAtRow:0] childNodes] count]);
		}
		else {
			return (![[self dataSource] outlineView:self numberOfChildrenOfItem:[self itemAtRow:0]]);
		}
	}
	return NO;
}
@end
