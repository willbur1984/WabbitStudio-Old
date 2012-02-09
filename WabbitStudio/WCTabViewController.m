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
#import "WCSourceTextView.h"
#import "WCFileContainer.h"
#import "WCFile.h"
#import "WCProjectWindowController.h"
#import "WCProjectNavigatorViewController.h"
#import "WCSourceHighlighter.h"
#import "NSTextView+WCExtensions.h"
#import <PSMTabBarControl/PSMTabBarControl.h>

NSString *const WCTabViewControllerDidSelectTabNotification = @"WCTabViewControllerDidSelectTabNotification";
NSString *const WCTabViewControllerDidCloseTabNotification = @"WCTabViewControllerDidCloseTabNotification";

static NSString *const WCTabViewControllerOpenTabsKey = @"openTabs";
static NSString *const WCTabViewControllerSelectedTabKey = @"selectedTab";

@interface WCTabViewController ()
@property (readwrite,assign,nonatomic) NSTabViewItem *clickedTabViewItem;
@property (readwrite,assign,nonatomic) BOOL ignoreChangesToProjectDocumentSettings;
@end

@implementation WCTabViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_clickedTabViewItem = nil;
	[_sourceFileDocumentsToSourceTextViewControllers release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_sourceFileDocumentsToSourceTextViewControllers = [[NSMapTable mapTableWithWeakToStrongObjects] retain];
	_tabViewControllerFlags.ignoreChangesToProjectDocumentSettings = YES;
	
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
	
	if ([[self delegate] respondsToSelector:@selector(projectDocumentSettingsForTabViewController:)]) {
		NSDictionary *settings = [[self delegate] projectDocumentSettingsForTabViewController:self];
		
		if ([[settings objectForKey:WCTabViewControllerOpenTabsKey] count]) {
			WCProjectDocument *projectDocument = [[self delegate] projectDocumentForTabViewController:self];
			NSDictionary *UUIDsToFiles = [projectDocument UUIDsToFiles];
			NSMapTable *filesToDocuments = [projectDocument filesToSourceFileDocuments];
			
			for (NSString *UUID in [settings objectForKey:WCTabViewControllerOpenTabsKey]) {
				WCFile *file = [UUIDsToFiles objectForKey:UUID];
				WCSourceFileDocument *document = [filesToDocuments objectForKey:file];
				
				if (document)
					[self addTabForSourceFileDocument:document];
			}
			
			if ([settings objectForKey:WCTabViewControllerSelectedTabKey]) {
				NSString *UUID = [settings objectForKey:WCTabViewControllerSelectedTabKey];
				WCFile *file = [UUIDsToFiles objectForKey:UUID];
				WCSourceFileDocument *document = [filesToDocuments objectForKey:file];
				NSUInteger itemIndex = [[[self tabBarControl] tabView] indexOfTabViewItemWithIdentifier:document];
				
				if (itemIndex != NSNotFound)
					[[[self tabBarControl] tabView] selectTabViewItemAtIndex:itemIndex];
			}
		}
	}
	
	[self setIgnoreChangesToProjectDocumentSettings:NO];
}
#pragma mark NSTabViewDelegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem; {
	[[NSNotificationCenter defaultCenter] postNotificationName:WCTabViewControllerDidSelectTabNotification object:self];
	
	//if (![self ignoreChangesToProjectDocumentSettings])
	//	[[[self delegate] projectDocumentForTabViewController:self] updateChangeCount:(NSChangeDone|NSChangeDiscardable)];
}
- (BOOL)tabView:(NSTabView *)tabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem; {
	return YES;
}
- (void)tabView:(NSTabView *)tabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem; {
	[tabViewItem unbind:@"label"];
	[self removeTabForSourceFileDocument:[tabViewItem identifier]];
	[[NSNotificationCenter defaultCenter] postNotificationName:WCTabViewControllerDidCloseTabNotification object:self];
	
	//if (![self ignoreChangesToProjectDocumentSettings])
	//	[[[self delegate] projectDocumentForTabViewController:self] updateChangeCount:(NSChangeDone|NSChangeDiscardable)];
}
#pragma mark PSMTabBarControlDelegate
- (NSString *)tabView:(NSTabView *)tabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem; {
	WCSourceFileDocument *sfDocument = [tabViewItem identifier];
	
	// just show the on-disk path to the file as the tool tip
	return [[[sfDocument fileURL] path] stringByAbbreviatingWithTildeInPath];
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
		
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Close \"%@\"", @"Close \"%@\""),[[[[self clickedTabViewItem] identifier] fileURL] fileName]]];
	}
	else if ([menuItem action] == @selector(_closeAllExceptTab:)) {
		if ([[[self tabBarControl] tabView] numberOfTabViewItems] <= 1)
			return NO;
		
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Close All Except \"%@\"", @"Close All Except \"%@\""),[[[[self clickedTabViewItem] identifier] fileURL] fileName]]];
	}
	else if ([menuItem action] == @selector(_showInFinder:)) {
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Show \"%@\" in Finder", @"Show \"%@\" in Finder"),[[[[self clickedTabViewItem] identifier] fileURL] fileName]]];
	}
	else if ([menuItem action] == @selector(_revealInProjectNavigator:)) {
		[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Reveal \"%@\" in Project Navigator", @"Reveal \"%@\" in Project Navigator"),[[[[self clickedTabViewItem] identifier] fileURL] fileName]]];
	}
	return YES;
}
#pragma mark WCProjectDocumentSettingsProvider
- (NSDictionary *)projectDocumentSettings {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	if ([[[self tabBarControl] tabView] numberOfTabViewItems]) {
		NSArray *documents = [[[self tabBarControl] representedTabViewItems] valueForKey:@"identifier"];
		NSMutableArray *UUIDs = [NSMutableArray arrayWithCapacity:[documents count]];
		
		for (WCSourceFileDocument *sfDocument in documents) {
			WCFile *file = [[[sfDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sfDocument];
			
			[UUIDs addObject:[file UUID]];
		}
		
		if ([UUIDs count])
			[retval setObject:UUIDs forKey:WCTabViewControllerOpenTabsKey];
		
		WCSourceFileDocument *sfDocument = [[[[self tabBarControl] tabView] selectedTabViewItem] identifier];
		WCFile *file = [[[sfDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sfDocument];
		
		if (file)
			[retval setObject:[file UUID] forKey:WCTabViewControllerSelectedTabKey];
	}
	
	return [[retval copy] autorelease];
}
- (NSString *)projectDocumentSettingsKey {
	return [self className];
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
		[tabViewItem setInitialFirstResponder:[stvController textView]];
		
		[_sourceFileDocumentsToSourceTextViewControllers setObject:stvController forKey:sourceFileDocument];
		
		WCFile *file = [[[sourceFileDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sourceFileDocument];
		
		[[[sourceFileDocument projectDocument] openFiles] addObject:file];
		
		[[[self tabBarControl] tabView] addTabViewItem:tabViewItem];
	}
	else
		tabViewItem = [[[self tabBarControl] tabView] tabViewItemAtIndex:tabViewItemIndex];
	
	[[[self tabBarControl] tabView] selectTabViewItem:tabViewItem];
	
	return [_sourceFileDocumentsToSourceTextViewControllers objectForKey:[tabViewItem identifier]];
}
- (void)removeTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	WCFile *file = [[[sourceFileDocument projectDocument] sourceFileDocumentsToFiles] objectForKey:sourceFileDocument];
	WCSourceTextViewController *stvController = [_sourceFileDocumentsToSourceTextViewControllers objectForKey:sourceFileDocument];
	
#ifdef DEBUG
    NSAssert(stvController, @"stvController cannot be nil!");
#endif
	
	[stvController performCleanup];
	
	[_sourceFileDocumentsToSourceTextViewControllers removeObjectForKey:sourceFileDocument];
	
	[[[sourceFileDocument projectDocument] openFiles] removeObject:file];
}
#pragma mark Properties
@synthesize tabBarControl=_tabBarControl;
@synthesize tabView=_tabView;
@synthesize clickedTabViewItem=_clickedTabViewItem;
@synthesize delegate=_delegate;
@dynamic ignoreChangesToProjectDocumentSettings;
- (BOOL)ignoreChangesToProjectDocumentSettings {
	return _tabViewControllerFlags.ignoreChangesToProjectDocumentSettings;
}
- (void)setIgnoreChangesToProjectDocumentSettings:(BOOL)ignoreChangesToProjectDocumentSettings {
	_tabViewControllerFlags.ignoreChangesToProjectDocumentSettings = ignoreChangesToProjectDocumentSettings;
}
@synthesize sourceFileDocumentsToSourceTextViewControllers=_sourceFileDocumentsToSourceTextViewControllers;
#pragma mark *** Private Methods ***

#pragma mark IBActions
- (IBAction)_closeTab:(id)sender {
	[[[self tabBarControl] tabView] removeTabViewItem:[self clickedTabViewItem]];
}
- (IBAction)_closeAllExceptTab:(id)sender {
	for (NSTabViewItem *tabViewItem in [[[[[self tabBarControl] tabView] tabViewItems] copy] autorelease]) {
		if (tabViewItem == [self clickedTabViewItem])
			continue;
		
		[[[self tabBarControl] tabView] removeTabViewItem:tabViewItem];
	}
}
- (IBAction)_showInFinder:(id)sender {
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:[NSArray arrayWithObjects:[[[self clickedTabViewItem] identifier] fileURL], nil]];
}
- (IBAction)_revealInProjectNavigator:(id)sender {
	WCFile *file = [[[[self delegate] projectDocumentForTabViewController:self] sourceFileDocumentsToFiles] objectForKey:[[self clickedTabViewItem] identifier]];
	
	[[[[[self delegate] projectDocumentForTabViewController:self] projectWindowController] projectNavigatorViewController] setSelectedModelObjects:[NSArray arrayWithObjects:file, nil]];
}
@end
