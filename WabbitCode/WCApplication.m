//
//  WCApplication.m
//  WabbitStudio
//
//  Created by William Towe on 3/9/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCApplication.h"
#import "RSDefines.h"
#import "WCProjectWindowController.h"
#import "WCSourceFileSeparateWindowController.h"
#import "WCSourceFileDocument.h"
#import "WCTabViewController.h"
#import "WCDocumentController.h"
#import "WCProjectDocument.h"
#import "WCSourceFileWindowController.h"

@interface WCApplication ()

@end

@implementation WCApplication
- (void)addWindowsItem:(NSWindow *)window title:(NSString *)aString filename:(BOOL)isFilename {
	[super addWindowsItem:window title:aString filename:isFilename];
	
	NSInteger itemIndex = [[self windowsMenu] indexOfItemWithTarget:window andAction:@selector(makeKeyAndOrderFront:)];
	
	if (itemIndex == -1)
		return;
	
	if ([[window windowController] isKindOfClass:[WCProjectWindowController class]]) {
		NSMenuItem *projectMenuItem = [[self windowsMenu] itemAtIndex:itemIndex];
		WCProjectWindowController *projectWindowController = [window windowController];
		
		[projectMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[[projectWindowController document] fileURL] path]]];
		[[projectMenuItem image] setSize:NSSmallSize];
	}
	else if ([[window windowController] isKindOfClass:[WCSourceFileSeparateWindowController class]]) {		
		WCProjectDocument *projectDocument = [[window windowController] document];
		NSInteger projectMenuItemIndex = [[self windowsMenu] indexOfItemWithTarget:[[projectDocument projectWindowController] window] andAction:@selector(makeKeyAndOrderFront:)];
		
		if (projectMenuItemIndex == -1)
			return;
		
		NSMenuItem *sourceFileMenuItem = [[[[self windowsMenu] itemAtIndex:itemIndex] retain] autorelease];
		WCSourceFileDocument *sourceFileDocument = [[window windowController] sourceFileDocument];
		
		[[self windowsMenu] removeItem:sourceFileMenuItem];
		
		projectMenuItemIndex = [[self windowsMenu] indexOfItemWithTarget:[[projectDocument projectWindowController] window] andAction:@selector(makeKeyAndOrderFront:)];
		
		[[self windowsMenu] insertItem:sourceFileMenuItem atIndex:++projectMenuItemIndex];
		
		[sourceFileMenuItem setTitle:[sourceFileDocument displayName]];
		[sourceFileMenuItem setIndentationLevel:1];
		[sourceFileMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[sourceFileDocument fileURL] path]]];
		[[sourceFileMenuItem image] setSize:NSSmallSize];
	}
	else if ([[window windowController] isKindOfClass:[WCSourceFileWindowController class]]) {
		NSMenuItem *sourceFileMenuItem = [[self windowsMenu] itemAtIndex:itemIndex];
		WCSourceFileDocument *sourceFileDocument = [[window windowController] document];
		
		[sourceFileMenuItem setTitle:[sourceFileDocument displayName]];
		
		if ([sourceFileDocument fileURL])
			[sourceFileMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[sourceFileDocument fileURL] path]]];
		else
			[sourceFileMenuItem setImage:[NSImage imageNamed:@"UntitledFile"]];
		
		[[sourceFileMenuItem image] setSize:NSSmallSize];
	}
}

- (void)changeWindowsItem:(NSWindow *)window title:(NSString *)aString filename:(BOOL)isFilename {
	[super changeWindowsItem:window title:aString filename:isFilename];
	
	NSInteger itemIndex = [[self windowsMenu] indexOfItemWithTarget:window andAction:@selector(makeKeyAndOrderFront:)];
	
	if (itemIndex == -1)
		return;
	
	if ([[window windowController] isKindOfClass:[WCProjectWindowController class]]) {
		NSMenuItem *projectMenuItem = [[self windowsMenu] itemAtIndex:itemIndex];
		WCProjectWindowController *projectWindowController = [window windowController];
		
		[projectMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[[projectWindowController document] fileURL] path]]];
		[[projectMenuItem image] setSize:NSSmallSize];
	}
	else if ([[window windowController] isKindOfClass:[WCSourceFileSeparateWindowController class]]) {		
		NSMenuItem *sourceFileMenuItem = [[[[self windowsMenu] itemAtIndex:itemIndex] retain] autorelease];
		WCSourceFileDocument *sourceFileDocument = [[[[[window windowController] tabViewController] tabView] selectedTabViewItem] identifier];
		
		if (!sourceFileDocument)
			return;
		
		[sourceFileMenuItem setTitle:[sourceFileDocument displayName]];
		[sourceFileMenuItem setIndentationLevel:1];
		[sourceFileMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[sourceFileDocument fileURL] path]]];
		[[sourceFileMenuItem image] setSize:NSSmallSize];
	}
	else if ([[window windowController] isKindOfClass:[WCSourceFileWindowController class]]) {
		NSMenuItem *sourceFileMenuItem = [[self windowsMenu] itemAtIndex:itemIndex];
		WCSourceFileDocument *sourceFileDocument = [[window windowController] document];
		
		[sourceFileMenuItem setTitle:[sourceFileDocument displayName]];
		
		if ([sourceFileDocument fileURL])
			[sourceFileMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[sourceFileDocument fileURL] path]]];
		else
			[sourceFileMenuItem setImage:[NSImage imageNamed:@"UntitledFile"]];
		
		[[sourceFileMenuItem image] setSize:NSSmallSize];
	}
}

- (void)removeWindowsItem:(NSWindow *)window {
	[super removeWindowsItem:window];
	
}

@end
