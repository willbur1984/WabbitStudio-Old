//
//  RSPreferencesWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 7/13/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSPreferencesWindowController.h"
#import "NSEvent+RSExtensions.h"

NSString *const RSPreferencesWindowControllerLastSelectedToolbarIdentifierKey = @"RSPreferencesWindowControllerLastSelectedToolbarIdentifierKey";

@interface RSPreferencesWindowController ()
- (NSRect)_frameForViewController:(id <RSPreferencesModule>)viewController;
@end

@implementation RSPreferencesWindowController
#pragma mark *** Subclass Overrides ***
- (id)initWithWindowNibName:(NSString *)windowNibName {
	if (!(self = [super initWithWindowNibName:windowNibName]))
		return nil;
	
	_viewControllers = [[NSMutableArray alloc] init];
	_identifiersToToolbarItems = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)windowWillLoad {
	[super windowWillLoad];
	
	[self setupViewControllers];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"%@Toolbar",[self className]]] autorelease];
	
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration:NO];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setSizeMode:NSToolbarSizeModeRegular];
	[toolbar setDelegate:self];
	
	[[self window] setToolbar:toolbar];
	
	NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:RSPreferencesWindowControllerLastSelectedToolbarIdentifierKey];
	
	if (identifier && [[self identifiersToToolbarItems] objectForKey:identifier])
		[self setCurrentPreferenceModule:[[self identifiersToToolbarItems] objectForKey:identifier]];
	else
		[self setCurrentPreferenceModule:[[self viewControllers] objectAtIndex:0]];
}

- (void)showWindow:(id)sender {
	[[self window] center];
	[super showWindow:nil];
}
#pragma mark NSToolbarDelegate
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	return [[self viewControllers] valueForKey:@"identifier"];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return [[self viewControllers] valueForKey:@"identifier"];
}
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return [[self viewControllers] valueForKey:@"identifier"];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	NSViewController <RSPreferencesModule> *viewController = [[self identifiersToToolbarItems] objectForKey:itemIdentifier];	
	
	[item setLabel:[viewController label]];
	[item setToolTip:[NSString stringWithFormat:NSLocalizedString(@"%@ Preferences", @"preferences toolbar item tooltip format string"),[item label]]];
	
	if ([viewController respondsToSelector:@selector(image)])
		[item setImage:[viewController image]];
	else
		[item setImage:[NSImage imageNamed:[item label]]];
	
	[item setAction:@selector(_toolbarItemAction:)];
	[item setTarget:self];
	
	return item;
}
#pragma mark NSAnimationDelegate
- (void)animationDidEnd:(NSAnimation *)animation {
	NSView *viewToRemove = nil;
	for (NSView *view in [[[self window] contentView] subviews]) {
		if ([[self currentPreferenceModule] view] != view) {
			viewToRemove = view;
			break;
		}
	}
	[viewToRemove removeFromSuperviewWithoutNeedingDisplay];
	
	[_swapAnimation release];
	_swapAnimation = nil;
	
	if ([[self currentPreferenceModule] respondsToSelector:@selector(initialFirstResponder)]) {
		if ([[[self currentPreferenceModule] initialFirstResponder] isKindOfClass:[NSTabView class]])
			[[self window] makeFirstResponder:[[(NSTabView *)[[self currentPreferenceModule] initialFirstResponder] selectedTabViewItem] initialFirstResponder]];
		else
			[[self window] makeFirstResponder:[[self currentPreferenceModule] initialFirstResponder]];
	}
}
#pragma mark *** Public Methods ***
+ (NSString *)windowNibName; {
	return @"RSPreferencesWindow";
}

+ (id)sharedWindowController {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] initWithWindowNibName:[self windowNibName]];
	});
	return sharedInstance;
}

- (void)setupViewControllers; {
	NSException *exception = [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:NSLocalizedString(@"%@ not implemented in subclass %@", @"RSPreferencesWindowController setupViewControllers not implemented format string"),NSStringFromSelector(_cmd),[self className]] userInfo:nil];
	
	[exception raise];
}

- (void)addViewController:(id <RSPreferencesModule>)viewController; {
	[_viewControllers addObject:viewController];
	[_identifiersToToolbarItems setObject:viewController forKey:[viewController identifier]];
}
#pragma mark Properties
@synthesize viewControllers=_viewControllers;
@synthesize identifiersToToolbarItems=_identifiersToToolbarItems;
@dynamic currentPreferenceModule;
- (id<RSPreferencesModule>)currentPreferenceModule {
	return _currentPreferenceModule;
}
- (void)setCurrentPreferenceModule:(id<RSPreferencesModule>)currentPreferenceModule {
	if (_currentPreferenceModule == currentPreferenceModule)
		return;
	
	if (!_currentPreferenceModule) {
		_currentPreferenceModule = currentPreferenceModule;
		
		NSRect newFrame = [self _frameForViewController:currentPreferenceModule];
		
		[[[self window] contentView] addSubview:[currentPreferenceModule view]];
		[[self window] setFrame:newFrame display:NO];
		
		if ([_currentPreferenceModule respondsToSelector:@selector(initialFirstResponder)]) {
			if ([[[self currentPreferenceModule] initialFirstResponder] isKindOfClass:[NSTabView class]])
				[[self window] makeFirstResponder:[[(NSTabView *)[[self currentPreferenceModule] initialFirstResponder] selectedTabViewItem] initialFirstResponder]];
			else
				[[self window] makeFirstResponder:[[self currentPreferenceModule] initialFirstResponder]];
		}
		
		[[[self window] toolbar] setSelectedItemIdentifier:[currentPreferenceModule identifier]];
	}
	else {
		NSRect newFrame = [self _frameForViewController:currentPreferenceModule];
		
		static const NSTimeInterval duration = 0.35;
		static const NSTimeInterval slowDuration = 1.25;
		
		[[[self window] contentView] addSubview:[currentPreferenceModule view] positioned:NSWindowBelow relativeTo:[_currentPreferenceModule view]];
		 
		_swapAnimation = [[NSViewAnimation alloc] initWithDuration:([NSEvent isOnlyShiftKeyPressed])?slowDuration:duration animationCurve:NSAnimationEaseInOut];
		
		[_swapAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		[_swapAnimation setDelegate:self];
		
		[_swapAnimation setViewAnimations:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[self window],NSViewAnimationTargetKey,[NSValue valueWithRect:newFrame],NSViewAnimationEndFrameKey, nil],[NSDictionary dictionaryWithObjectsAndKeys:[_currentPreferenceModule view],NSViewAnimationTargetKey,NSViewAnimationFadeOutEffect,NSViewAnimationEffectKey, nil],[NSDictionary dictionaryWithObjectsAndKeys:[currentPreferenceModule view],NSViewAnimationTargetKey,NSViewAnimationFadeInEffect,NSViewAnimationEffectKey, nil], nil]];
	
		_currentPreferenceModule = currentPreferenceModule;
		
		[[self window] makeFirstResponder:nil];
		
		[_swapAnimation startAnimation];
		
		[[NSUserDefaults standardUserDefaults] setObject:[_currentPreferenceModule identifier] forKey:RSPreferencesWindowControllerLastSelectedToolbarIdentifierKey];
	}
	
	[[self window] setTitle:[_currentPreferenceModule label]];
}
#pragma mark *** Private Methods ***
- (void)_toolbarItemAction:(NSToolbarItem *)sender {
	NSViewController <RSPreferencesModule> *viewController = [[self identifiersToToolbarItems] objectForKey:[sender itemIdentifier]];
	
	[self setCurrentPreferenceModule:viewController];	
}

- (NSRect)_frameForViewController:(id <RSPreferencesModule>)viewController; {
	NSRect windowFrame = [[self window] frame];
	NSRect contentRect = [[self window] contentRectForFrameRect:windowFrame];
	CGFloat windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
	
	windowFrame.size.height = NSHeight([[viewController view] frame]) + windowTitleAndToolbarHeight;
	windowFrame.size.width = NSWidth([[viewController view] frame]);
	windowFrame.origin.y = NSMaxY([[self window] frame]) - NSHeight(windowFrame);
	
	return windowFrame;
}
@end
