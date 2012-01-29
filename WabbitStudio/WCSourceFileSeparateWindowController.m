//
//  WCSourceFileSeparateWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/29/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceFileSeparateWindowController.h"
#import "WCTabViewController.h"
#import "WCSourceFileDocument.h"
#import "WCProjectDocument.h"
#import <PSMTabBarControl/PSMTabBarControl.h>

@implementation WCSourceFileSeparateWindowController

- (void)dealloc {
	_sourceFileDocument = nil;
	[_tabViewController release];
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WCSourceFileSeparateWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[[self tabViewController] view] setFrameSize:[[[self window] contentView] frame].size];
	[[[self window] contentView] addSubview:[[self tabViewController] view]];
	
	[[[self tabViewController] tabBarControl] setCanCloseOnlyTab:NO];
	
	[[self projectDocument] openTabForSourceFileDocument:[self sourceFileDocument] tabViewContext:self];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	if ([[[[self tabViewController] tabBarControl] tabView] numberOfTabViewItems])
		return [NSString stringWithFormat:NSLocalizedString(@"%@ - %@",@"source file separate window controller window title format string"),displayName,[[[[[[self tabViewController] tabBarControl] tabView] selectedTabViewItem] identifier] displayName]];
	return displayName;
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
	while ([[[self tabViewController] tabView] numberOfTabViewItems])
		[[[self tabViewController] tabView] removeTabViewItem:[[[self tabViewController] tabView] tabViewItemAtIndex:0]];
}

#pragma mark WCTabViewControllerDelegate
- (WCProjectDocument *)projectDocumentForTabViewController:(WCTabViewController *)tabViewController {
	return [self projectDocument];
}

- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_sourceFileDocument = sourceFileDocument;
	
	_tabViewController = [[WCTabViewController alloc] init];
	[_tabViewController setDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabViewControllerDidCloseTab:) name:WCTabViewControllerDidCloseTabNotification object:_tabViewController];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabViewControllerDidSelectTab:) name:WCTabViewControllerDidSelectTabNotification object:_tabViewController];
	
	return self;
}

@synthesize tabViewController=_tabViewController;
@dynamic projectDocument;
- (WCProjectDocument *)projectDocument {
	return [self document];
}
@synthesize sourceFileDocument=_sourceFileDocument;

- (void)_tabViewControllerDidCloseTab:(NSNotification *)note {
	[self synchronizeWindowTitleWithDocumentName];
}
- (void)_tabViewControllerDidSelectTab:(NSNotification *)note {
	[self synchronizeWindowTitleWithDocumentName];
}

@end
