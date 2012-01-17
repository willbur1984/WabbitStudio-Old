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
#import <Quartz/Quartz.h>

@implementation WCProjectWindowController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
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

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
	if ([splitView isVertical] && view == [[splitView subviews] objectAtIndex:0])
		return NO;
	return YES;
}

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
@end
