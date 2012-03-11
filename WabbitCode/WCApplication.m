//
//  WCApplication.m
//  WabbitStudio
//
//  Created by William Towe on 3/9/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
		[sourceFileMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[sourceFileDocument fileURL] path]]];
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
		[sourceFileMenuItem setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[sourceFileDocument fileURL] path]]];
		[[sourceFileMenuItem image] setSize:NSSmallSize];
	}
}

- (void)removeWindowsItem:(NSWindow *)window {
	[super removeWindowsItem:window];
	
}

@end
