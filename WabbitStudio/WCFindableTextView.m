//
//  WCFindableTextView.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFindableTextView.h"
#import "RSFindBarViewController.h"
#import "WCKeyboardViewController.h"

@implementation WCFindableTextView
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_findBarViewController release];
	[super dealloc];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:_windowWillCloseObservingToken];
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	
	if ([self window]) {
		_windowWillCloseObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:[self window] queue:nil usingBlock:^(NSNotification *note) {
			if ([_findBarViewController isFindBarVisible])
				[_findBarViewController performCleanup];
		}];
	}
}

- (IBAction)performTextFinderAction:(id)sender {
	switch ([sender tag]) {
		case NSTextFinderActionShowFindInterface:
			[[self findBarViewController] showFindBar:nil];
			break;
		case NSTextFinderActionHideFindInterface:
			[[self findBarViewController] hideFindBar:nil];
			break;
		case NSTextFinderActionNextMatch:
			[[self findBarViewController] findNext:nil];
			break;
		case NSTextFinderActionPreviousMatch:
			[[self findBarViewController] findPrevious:nil];
			break;
		case NSTextFinderActionSetSearchString:
			[[self findBarViewController] setFindString:[[self string] substringWithRange:[self selectedRange]]];
			
			if ([[self findBarViewController] isFindBarVisible])
				[[self findBarViewController] find:nil];
			else
				[[self findBarViewController] showFindBar:nil];
			break;
		case NSTextFinderActionShowReplaceInterface:
			[[self findBarViewController] showReplaceControls:nil];
			break;
		case NSTextFinderActionReplace:
		case NSTextFinderActionReplaceAll:
		case NSTextFinderActionReplaceAllInSelection:
		case NSTextFinderActionReplaceAndFind:
		default:
			break;
	}
}

- (IBAction)scrollToBeginningOfDocument:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:WCKeyboardHomeAndEndKeysBehaviorKey] unsignedIntegerValue] == WCKeyboardHomeAndEndKeysBehaviorScrollToBeginningAndEndOfDocument) {
		[super scrollToBeginningOfDocument:nil];
		return;
	}
	
	NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
	
	[self setSelectedRange:NSMakeRange(lineRange.location, 0)];
}

- (IBAction)scrollToEndOfDocument:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:WCKeyboardHomeAndEndKeysBehaviorKey] unsignedIntegerValue] == WCKeyboardHomeAndEndKeysBehaviorScrollToBeginningAndEndOfDocument) {
		[super scrollToEndOfDocument:nil];
		return;
	}
	
	NSRange lineRange = [[self string] lineRangeForRange:[self selectedRange]];
	
	[self setSelectedRange:NSMakeRange(NSMaxRange(lineRange), 0)];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
	if ([anItem action] == @selector(performTextFinderAction:)) {
		switch ([anItem tag]) {
			case NSTextFinderActionShowFindInterface:
			case NSTextFinderActionPreviousMatch:
			case NSTextFinderActionNextMatch:
				return YES;
			case NSTextFinderActionHideFindInterface:
				return [_findBarViewController isFindBarVisible];
			case NSTextFinderActionSetSearchString:
				return ([self selectedRange].length > 0);
			case NSTextFinderActionShowReplaceInterface:
			case NSTextFinderActionReplace:
			case NSTextFinderActionReplaceAll:
			case NSTextFinderActionReplaceAllInSelection:
			case NSTextFinderActionReplaceAndFind:
				return [self isEditable];
			default:
				return NO;
				break;
		}
	}
	return [super validateUserInterfaceItem:anItem];
}

@dynamic findBarViewController;
- (RSFindBarViewController *)findBarViewController {
	if (!_findBarViewController) {
		_findBarViewController = [[RSFindBarViewController alloc] initWithTextView:self];
	}
	return _findBarViewController;
}
@end
