//
//  RSTabViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTabViewController.h"
#import "WCSourceFileDocument.h"
#import "WCStandardSourceTextViewController.h"
#import "NSURL+RSExtensions.h"
#import "WCProjectDocument.h"
#import <PSMTabBarControl/PSMTabBarControl.h>

NSString *const WCTabViewControllerDidSelectTabNotification = @"WCTabViewControllerDidSelectTabNotification";
NSString *const WCTabViewControllerDidCloseTabNotification = @"WCTabViewControllerDidCloseTabNotification";

@interface WCTabViewController ()
@property (readwrite,assign,nonatomic) NSTabViewItem *clickedTabViewItem;
@end

@implementation WCTabViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	_clickedTabViewItem = nil;
	[_sourceFileDocumentsToSourceTextViewControllers release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_sourceFileDocumentsToSourceTextViewControllers = [[NSMapTable mapTableWithWeakToStrongObjects] retain];
	
	return self;
}

- (NSString *)nibName {
	return @"WCTabView";
}

- (void)loadView {
	[super loadView];
	
	[[self tabBarControl] setStyleNamed:@"Unified"];
	[[self tabBarControl] setShowAddTabButton:NO];
	[[self tabBarControl] setAllowsBackgroundTabClosing:YES];
	[[self tabBarControl] setAlwaysShowActiveTab:YES];
	[[self tabBarControl] setAutomaticallyAnimates:NO];
	[[self tabBarControl] setHideForSingleTab:NO];
	[[self tabBarControl] setCanCloseOnlyTab:YES];
	[[self tabBarControl] setTearOffStyle:PSMTabBarTearOffMiniwindow];
	[[self tabBarControl] setUseOverflowMenu:YES];
}
#pragma mark NSTabViewDelegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem; {
	[[NSNotificationCenter defaultCenter] postNotificationName:WCTabViewControllerDidSelectTabNotification object:self];
}
- (BOOL)tabView:(NSTabView *)tabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem; {
	return YES;
}
- (void)tabView:(NSTabView *)tabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem; {
	[tabViewItem unbind:@"label"];
	[self removeTabForSourceFileDocument:[tabViewItem identifier]];
	[[NSNotificationCenter defaultCenter] postNotificationName:WCTabViewControllerDidCloseTabNotification object:self];
}
#pragma mark PSMTabBarControlDelegate
- (NSString *)tabView:(NSTabView *)tabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem; {
	WCSourceFileDocument *sfController = [tabViewItem identifier];
	
	// just show the on-disk path to the file as the tool tip
	return [[[sfController fileURL] path] stringByAbbreviatingWithTildeInPath];
}

- (NSMenu *)tabView:(NSTabView *)aTabView menuForTabViewItem:(NSTabViewItem *)tabViewItem {
	NSMenu *tabViewMenu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	
	// close tab
	[tabViewMenu addItemWithTitle:NSLocalizedString(@"Close Tab", @"Close Tab") action:@selector(_closeTab:) keyEquivalent:@""];
	[[[tabViewMenu itemArray] lastObject] setTarget:self];
	// close all but this tab
	[tabViewMenu addItemWithTitle:NSLocalizedString(@"Close All Except Tab", @"Close All Except Tab") action:@selector(_closeAllExceptTab:) keyEquivalent:@""];
	[[[tabViewMenu itemArray] lastObject] setTarget:self];
	[tabViewMenu addItem:[NSMenuItem separatorItem]];
	// show in finder
	[tabViewMenu addItemWithTitle:NSLocalizedString(@"Show in Finder", @"Show in Finder") action:@selector(_showInFinder:) keyEquivalent:@""];
	[[[tabViewMenu itemArray] lastObject] setTarget:self];
	[tabViewMenu addItem:[NSMenuItem separatorItem]];
	// reveal in project navigator
	[tabViewMenu addItemWithTitle:NSLocalizedString(@"Reveal in Project Navigator", @"Reveal in Project Navigator") action:@selector(_revealInProjectNavigator:) keyEquivalent:@""];
	[[[tabViewMenu itemArray] lastObject] setTarget:self];
	
	[self setClickedTabViewItem:tabViewItem];
	
	return tabViewMenu;
}

- (BOOL)tabView:(NSTabView *)tabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl {
	if ([tabView numberOfTabViewItems] <= 1)
		return NO;
	return YES;
}
- (BOOL)tabView:(NSTabView *)tabView shouldDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBar:(PSMTabBarControl *)tabBarControl {
	return (tabView == [tabBarControl tabView]);
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(_closeTab:)) {
		if (![[self tabBarControl] canCloseOnlyTab] &&
			[[[self tabBarControl] tabView] numberOfTabViewItems] == 1)
			return NO;
		else if (![[[self tabBarControl] tabView] numberOfTabViewItems])
			return NO;
	}
	else if ([menuItem action] == @selector(_closeAllExceptTab:)) {
		if ([[[self tabBarControl] tabView] numberOfTabViewItems] <= 1)
			return NO;
	}
	else if ([menuItem action] == @selector(_showInFinder:)) {
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Show \"%@\" in Finder", @"Show \"%@\" in Finder"),[[[[self clickedTabViewItem] identifier] fileURL] fileName]]];
	}
	else if ([menuItem action] == @selector(_revealInProjectNavigator:)) {
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Reveal \"%@\" in Project Navigator", @"Reveal \"%@\" in Project Navigator"),[[[[self clickedTabViewItem] identifier] fileURL] fileName]]];
	}
	return YES;
}
#pragma mark *** Public Methods ***
- (WCSourceTextViewController *)addTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
#ifdef DEBUG
    NSAssert(sourceFileDocument, @"sourceFileDocument cannot be nil!");
#endif
	
	NSUInteger tabViewItemIndex = [[[self tabBarControl] tabView] indexOfTabViewItemWithIdentifier:sourceFileDocument];
	NSTabViewItem *tabViewItem;
	
	if (tabViewItemIndex == NSNotFound) {
		tabViewItem = [[[NSTabViewItem alloc] initWithIdentifier:sourceFileDocument] autorelease];
		
		[tabViewItem bind:@"label" toObject:[[[sourceFileDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sourceFileDocument] withKeyPath:@"fileName" options:nil];
		
		WCStandardSourceTextViewController *stvController = [[[WCStandardSourceTextViewController alloc] initWithSourceFileDocument:sourceFileDocument] autorelease];
		NSView *containerView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 500)] autorelease];
		//[containerView setAutoresizesSubviews:YES];
		[containerView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMinYMargin];
		[[stvController view] setFrameSize:[containerView frame].size];
		[containerView addSubview:[stvController view]];
		
		[tabViewItem setView:containerView];
		
		[_sourceFileDocumentsToSourceTextViewControllers setObject:stvController forKey:sourceFileDocument];
		
		[[[self tabBarControl] tabView] addTabViewItem:tabViewItem];
		[[[self tabBarControl] tabView] selectTabViewItem:tabViewItem];
	}
	else
		tabViewItem = [[[self tabBarControl] tabView] tabViewItemAtIndex:tabViewItemIndex];
	
	return [_sourceFileDocumentsToSourceTextViewControllers objectForKey:[tabViewItem identifier]];
}
- (void)removeTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	WCSourceTextViewController *stvController = [_sourceFileDocumentsToSourceTextViewControllers objectForKey:sourceFileDocument];
	
#ifdef DEBUG
    NSAssert(stvController, @"stvController cannot be nil!");
#endif
	
	[_sourceFileDocumentsToSourceTextViewControllers removeObjectForKey:sourceFileDocument];
}
#pragma mark Properties
@synthesize tabBarControl=_tabBarControl;
@synthesize clickedTabViewItem=_clickedTabViewItem;
#pragma mark *** Private Methods ***

#pragma mark IBActions
- (IBAction)_closeTab:(id)sender {
	
}
- (IBAction)_closeAllExceptTab:(id)sender {
	
}
- (IBAction)_showInFinder:(id)sender {
	
}
- (IBAction)_revealInProjectNavigator:(id)sender {
	
}
@end
