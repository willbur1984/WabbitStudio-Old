//
//  WCAdvancedViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCAdvancedViewController.h"
#import "WCReallyAdvancedViewController.h"
#import "WCKeyboardViewController.h"
#import "WCAlertsViewController.h"

static NSString *const WCAdvancedViewControllerLastSelectedTabViewItemIdentifierKey = @"WCAdvancedViewControllerLastSelectedTabViewItemIdentifierKey";

@implementation WCAdvancedViewController

#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_identifiers release];
	[_viewControllers release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_viewControllers = [[NSMutableArray alloc] initWithCapacity:0];
	_identifiers = [[NSMutableSet alloc] initWithCapacity:0];
	
	return self;
}

- (NSString *)nibName {
	return @"WCAdvancedView";
}

- (void)loadView {
	[super loadView];
	
	[self addViewController:[[[WCAlertsViewController alloc] init] autorelease]];
	[self addViewController:[[[WCKeyboardViewController alloc] init] autorelease]];
	[self addViewController:[[[WCReallyAdvancedViewController alloc] init] autorelease]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tableViewSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:[self tableView]];
	
	NSString *lastIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:WCAdvancedViewControllerLastSelectedTabViewItemIdentifierKey];
	id <RSPreferencesModule> lastModule = nil;
	
	for (id <RSPreferencesModule> module in _viewControllers) {
		if ([[module identifier] isEqualToString:lastIdentifier]) {
			lastModule = module;
			break;
		}
	}
	
	if (!lastModule)
		lastModule = [_viewControllers objectAtIndex:0];
	
	[[self arrayController] setSelectedObjects:[NSArray arrayWithObject:lastModule]];
}
#pragma mark NSSplitViewDelegate
- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
	return [splitView convertRect:[[self splitterHandleImageView] bounds] fromView:[self splitterHandleImageView]];
}
static const CGFloat kMinLeftSubviewWidth = 150.0;
static const CGFloat kMaxLeftSubviewWidth = 250.0;
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMinimumPosition + kMinLeftSubviewWidth;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMaximumPosition - kMaxLeftSubviewWidth;
}

#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitcode.advanced";
}

- (NSString *)label {
	return NSLocalizedString(@"Advanced", @"Advanced");
}

- (NSImage *)image {
	return [NSImage imageNamed:NSImageNameAdvanced];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[retval addEntriesFromDictionary:[WCKeyboardViewController userDefaults]];
	[retval addEntriesFromDictionary:[WCReallyAdvancedViewController userDefaults]];
	[retval addEntriesFromDictionary:[WCAlertsViewController userDefaults]];
	
	return [[retval copy] autorelease];
}
#pragma mark *** Public Methods ***
- (void)addViewController:(id <RSPreferencesModule>)viewController; {
	if ([_identifiers containsObject:[viewController identifier]])
		return;
	
	[self willChangeValueForKey:@"viewControllers"];
	
	[_viewControllers addObject:viewController];
	[_identifiers addObject:[viewController identifier]];
	
	NSTabViewItem *item = [[[NSTabViewItem alloc] initWithIdentifier:viewController] autorelease];
	
	[item setLabel:[viewController label]];
	[item setView:[viewController view]];
	
	[[self tabView] addTabViewItem:item];
	
	[self didChangeValueForKey:@"viewControllers"];
}
#pragma mark Properties
@synthesize initialFirstResponder=_initialFirstResponder;
@synthesize splitterHandleImageView=_splitterHandleImageView;
@synthesize tableView=_tableView;
@synthesize tabView=_tabView;
@synthesize arrayController=_arrayController;

@synthesize viewControllers=_viewControllers;
#pragma mark *** Private Methods ***
#pragma mark Notifications
- (void)_tableViewSelectionDidChange:(NSNotification *)note {
	[[self tabView] selectTabViewItemWithIdentifier:[[[self arrayController] selectedObjects] lastObject]];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[[[self arrayController] selectedObjects] lastObject] identifier] forKey:WCAdvancedViewControllerLastSelectedTabViewItemIdentifierKey];
}
@end
