//
//  WCProjectWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectWindowController.h"
#import "RSNavigatorControl.h"
#import "RSDefines.h"
#import "WCProjectNavigatorViewController.h"
#import "WCProjectDocument.h"
#import "WCProject.h"
#import "WCTabViewController.h"
#import <PSMTabBarControl/PSMTabBarControl.h>
#import <Quartz/Quartz.h>

@implementation WCProjectWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_tabViewController release];
	[_projectNavigatorViewController release];
	[_navigatorItemDictionaries release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_navigatorItemDictionaries = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"project",@"identifier",[NSImage imageNamed:@"project"],@"image",NSLocalizedString(@"Show the project navigator", @"Show the project navigator"),@"toolTip", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"search",@"identifier",[NSImage imageNamed:@"Search"],@"image",NSLocalizedString(@"Show the search navigator", @"Show the search navigator"),@"toolTip", nil], nil];
	_tabViewController = [[WCTabViewController alloc] init];
	[_tabViewController setDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabViewControllerDidCloseTab:) name:WCTabViewControllerDidCloseTabNotification object:_tabViewController];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabViewControllerDidSelectTab:) name:WCTabViewControllerDidSelectTabNotification object:_tabViewController];
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
	
	[[[self tabViewController] view] setFrameSize:[[[[self splitView] subviews] lastObject] frame].size];
	[[self splitView] replaceSubview:[[[self splitView] subviews] lastObject] with:[[self tabViewController] view]];
	
	[[self navigatorControl] setSelectedItemIdentifier:@"project"];
}

- (void)setDocument:(NSDocument *)document {
	[super setDocument:document];
	
	[[[self document] projectSettingsProviders] addObject:self];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	if ([[[[self tabViewController] tabBarControl] tabView] numberOfTabViewItems])
		return [NSString stringWithFormat:NSLocalizedString(@"%@ - %@",@"project window controller window title format string"),displayName,[[[[[[self tabViewController] tabBarControl] tabView] selectedTabViewItem] identifier] displayName]];
	return displayName;
}
#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
	if ([splitView isVertical] && view == [[splitView subviews] objectAtIndex:0])
		return NO;
	return YES;
}
static const CGFloat kLeftSubviewMinWidth = 200.0;
static const CGFloat kRightSubviewMinWidth = 400.0;
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMaximumPosition-kRightSubviewMinWidth;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMinimumPosition+kLeftSubviewMinWidth;
}
#pragma mark WCTabViewControllerDelegate
- (WCProjectDocument *)projectDocumentForTabViewController:(WCTabViewController *)tabViewController {
	return [self document];
}
- (NSDictionary *)projectDocumentSettingsForTabViewController:(WCTabViewController *)tabViewController; {
	return [[[[self document] projectSettings] objectForKey:[self projectDocumentSettingsKey]] objectForKey:[tabViewController projectDocumentSettingsKey]];
}

#pragma mark RSNavigatorControlDataSource
- (NSArray *)itemIdentifiersForNavigatorControl:(RSNavigatorControl *)navigatorControl {
	return [_navigatorItemDictionaries valueForKey:@"identifier"];
}
- (CGFloat)itemWidthForNavigatorControl:(RSNavigatorControl *)navigatorControl {
	return floor(NSSmallSize.width*2);
}
- (NSImage *)navigatorControl:(RSNavigatorControl *)navigatorControl imageForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index {
	return [[_navigatorItemDictionaries objectAtIndex:index] objectForKey:@"image"];
}
- (NSString *)navigatorControl:(RSNavigatorControl *)navigatorControl toopTipForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index {
	return [[_navigatorItemDictionaries objectAtIndex:index] objectForKey:@"toolTip"];
}
#pragma mark RSNavigatorControlDelegate
- (NSView *)navigatorControl:(RSNavigatorControl *)navigatorControl contentViewForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index {
	if ([itemIdentifier isEqualToString:@"project"])
		return [[self projectNavigatorViewController] view];
	return nil;
}

- (void)navigatorControlSelectedItemIdentifierDidChange:(RSNavigatorControl *)navigatorControl {
	if (![[[self navigatorControl] selectedItemIdentifier] isEqualToString:@"project"] &&
		[QLPreviewPanel sharedPreviewPanelExists] &&
		[[QLPreviewPanel sharedPreviewPanel] isVisible]) {
		
		[[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
	}
}
#pragma mark WCProjectDocumentSettingsProvider
- (NSDictionary *)projectDocumentSettings {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[retval setObject:[[self tabViewController] projectDocumentSettings] forKey:[[self tabViewController] projectDocumentSettingsKey]];	
	
	return [[retval copy] autorelease];
}
- (NSString *)projectDocumentSettingsKey {
	return [self className];
}

#pragma mark QLPreviewPanelController
- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel; {
	return YES;
}
- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel; {
	[panel setDataSource:[self projectNavigatorViewController]];
	[panel setDelegate:[self projectNavigatorViewController]];
}
- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
	[panel setDataSource:nil];
	[panel setDelegate:nil];
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@synthesize navigatorControl=_navigatorControl;
@synthesize splitView=_splitView;

@dynamic projectNavigatorViewController;
- (WCProjectNavigatorViewController *)projectNavigatorViewController {
	if (!_projectNavigatorViewController) {
		_projectNavigatorViewController = [[WCProjectNavigatorViewController alloc] initWithProjectContainer:[[self document] projectContainer]];
	}
	return _projectNavigatorViewController;
}
@synthesize tabViewController=_tabViewController;

- (void)_tabViewControllerDidCloseTab:(NSNotification *)note {
	[self synchronizeWindowTitleWithDocumentName];
}
- (void)_tabViewControllerDidSelectTab:(NSNotification *)note {
	[self synchronizeWindowTitleWithDocumentName];
}
@end
