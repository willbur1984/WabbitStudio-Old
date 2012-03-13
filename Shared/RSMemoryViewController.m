//
//  RSMemoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSMemoryViewController.h"
#import "RSCalculator.h"
#import "RSRegularMemoryViewController.h"

#import <PSMTabBarControl/PSMTabBarControl.h>

@interface RSMemoryViewController ()

@end

@implementation RSMemoryViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_memoryViews release];
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSMemoryView";
}

- (void)loadView {
	[super loadView];
	
	[[self tabBarControl] setStyleNamed:@"Unified"];
	[[self tabBarControl] setShowAddTabButton:NO];
	[[self tabBarControl] setAllowsBackgroundTabClosing:YES];
	[[self tabBarControl] setAlwaysShowActiveTab:YES];
	[[self tabBarControl] setAutomaticallyAnimates:NO];
	[[self tabBarControl] setHideForSingleTab:NO];
	[[self tabBarControl] setCanCloseOnlyTab:NO];
	[[self tabBarControl] setTearOffStyle:PSMTabBarTearOffAlphaWindow];
	[[self tabBarControl] setUseOverflowMenu:YES];
	
	RSRegularMemoryViewController *regularMemoryView = [[[RSRegularMemoryViewController alloc] initWithCalculator:[self calculator]] autorelease];
	NSTabViewItem *item = [[[NSTabViewItem alloc] initWithIdentifier:regularMemoryView] autorelease];
	
	[item setLabel:NSLocalizedString(@"Memory", @"Memory")];
	[item setView:[regularMemoryView view]];
	
	[[[self tabBarControl] tabView] addTabViewItem:item];
	[[[self tabBarControl] tabView] selectTabViewItem:item];
	
	[_memoryViews addObject:regularMemoryView];
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	_memoryViews = [[NSMutableSet alloc] initWithCapacity:0];
	
	return self;
}

- (IBAction)jumpToAddress:(id)sender; {
	//id <RSCalculatorMemoryView> memoryView = [[[[self tabBarControl] tabView] selectedTabViewItem] identifier];
	
	
}
- (IBAction)jumpToProgramCounter:(id)sender; {
	id <RSCalculatorMemoryView> memoryView = [[[[self tabBarControl] tabView] selectedTabViewItem] identifier];
	
	[memoryView jumpToMemoryAddress:[[self calculator] programCounter]];
}

@synthesize tabBarControl=_tabBarControl;

@synthesize calculator=_calculator;

@end
