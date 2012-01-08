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
#import "NSTextView+WCExtensions.h"
#import "RSDefines.h"

@implementation WCFindableTextView
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_findBarViewController release];
	[super dealloc];
}

- (BOOL)isOpaque {
	return YES;
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
			[[self findBarViewController] replace:nil];
			break;
		case NSTextFinderActionReplaceAll:
			[[self findBarViewController] replaceAll:nil];
			break;
		case NSTextFinderActionReplaceAndFind:
			[[self findBarViewController] replaceAndFind:nil];
			break;
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
/*
- (BOOL)allowsMultipleSelection {
	return NO;
}
- (NSRange)firstSelectedRange {
	return [self selectedRange];
}
- (BOOL)shouldReplaceCharactersInRanges:(NSArray *)ranges withStrings:(NSArray *)strings {
	return [self shouldChangeTextInRanges:ranges replacementStrings:strings];
}
- (void)didReplaceCharacters {
	[self didChangeText];
}
- (NSView *)contentViewAtIndex:(NSUInteger)index effectiveCharacterRange:(NSRangePointer)outRange {
	if (outRange) {
		*outRange = NSMakeRange(0, [[self string] length]);
	}
	return self;
}
- (NSArray *)rectsForCharacterRange:(NSRange)range {
	NSUInteger rectCount;
	NSRectArray rects = [[self layoutManager] rectArrayForCharacterRange:range withinSelectedCharacterRange:NSNotFoundRange inTextContainer:[self textContainer] rectCount:&rectCount];
	
	if (rectCount) {
		NSMutableArray *rectArray = [NSMutableArray arrayWithCapacity:rectCount];
		NSUInteger rectIndex;
		
		for (rectIndex=0; rectIndex<rectCount; rectIndex++)
			[rectArray addObject:[NSValue valueWithRect:rects[rectIndex]]];
		
		return rectArray;
	}
	return nil;
}
- (NSArray *)visibleCharacterRanges {
	return [NSArray arrayWithObject:[NSValue valueWithRange:[self visibleRange]]];
}
*/
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

- (void)performCleanup; {
	[_findBarViewController performCleanup];
}

@dynamic findBarViewController;
- (RSFindBarViewController *)findBarViewController {
	if (!_findBarViewController) {
		_findBarViewController = [[RSFindBarViewController alloc] initWithTextView:self];
	}
	return _findBarViewController;
}
@end
