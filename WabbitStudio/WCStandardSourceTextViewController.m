//
//  WCStandardSourceTextViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/10/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCStandardSourceTextViewController.h"
#import "WCSplitView.h"
#import "NSArray+WCExtensions.h"
#import "WCSourceTextView.h"
#import "NSEvent+RSExtensions.h"
#import "WCSourceHighlighter.h"
#import "WCSourceTextStorage.h"
#import "RSDefines.h"
#import "WCJumpBarViewController.h"

@interface WCStandardSourceTextViewController ()
@property (readonly,nonatomic) WCSplitView *firstSplitView;
@property (readonly,nonatomic) WCSplitView *configuredSplitView;
@property (readonly,nonatomic) WCSourceTextViewController *firstTextViewController;
@property (readonly,nonatomic) WCSourceTextViewController *configuredSourceTextViewController;
@end

@implementation WCStandardSourceTextViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_assistantSourceTextViewControllers release];
	[_assistantSplitViews release];
	[super dealloc];
}

- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument standardSourceTextViewController:(WCStandardSourceTextViewController *)sourceTextViewController {
	if (!(self = [super initWithSourceFileDocument:sourceFileDocument standardSourceTextViewController:sourceTextViewController]))
		return nil;
	
	_assistantSplitViews = [[NSMutableArray alloc] initWithCapacity:0];
	_assistantSourceTextViewControllers = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}
#pragma mark IBActions
- (IBAction)showStandardEditor:(id)sender {
	if ([_assistantSplitViews count]) {
		NSView *contentView = [[self firstSplitView] superview];
		
		[[self view] removeFromSuperviewWithoutNeedingDisplay];
		[[self firstSplitView] removeFromSuperviewWithoutNeedingDisplay];
		
		[[self view] setFrame:[contentView frame]];
		[contentView addSubview:[self view]];
		
		for (WCSourceTextViewController *controller in _assistantSourceTextViewControllers)
			[[self textStorage] removeLayoutManager:[[controller textView] layoutManager]];
		
		[_assistantSplitViews removeAllObjects];
		[_assistantSourceTextViewControllers removeAllObjects];
	}
	
	[[[self view] window] makeFirstResponder:[self textView]];
}
- (IBAction)showAssistantEditor:(id)sender {
	// the first split view hasn't been created yet
	if (![_assistantSplitViews count]) {
		NSView *contentView = [[self view] superview];
		BOOL verticalSplitView = [NSEvent isOptionKeyPressed];
		if (verticalSplitView) {
			[[self firstSplitView] setDividerStyle:NSSplitViewDividerStylePaneSplitter];
			[[self firstSplitView] setVertical:YES];
		}
		else {
			[[self firstSplitView] setDividerStyle:NSSplitViewDividerStyleThin];
			[[self firstSplitView] setVertical:NO];
		}
		
		[[self view] removeFromSuperviewWithoutNeedingDisplay];
		[[self firstSplitView] setFrame:[contentView frame]];
		[contentView addSubview:[self firstSplitView]];
		
		[[self firstSplitView] addSubview:[self view]];
		[[self firstSplitView] addSubview:[[self firstTextViewController] view]];
		
		NSRect firstSubviewFrame = [[self view] frame];
		NSRect secondSubviewFrame = [[[self firstTextViewController] view] frame];
		CGFloat total;
		
		if (verticalSplitView) {
			total = NSWidth(firstSubviewFrame)+NSWidth(secondSubviewFrame)+[[self firstSplitView] dividerThickness];
			firstSubviewFrame.size.width = floor(total/2.0);
			secondSubviewFrame.size.width = total-NSWidth(firstSubviewFrame)-[[self firstSplitView] dividerThickness];
		}
		else {
			total = NSHeight(firstSubviewFrame)+NSHeight(secondSubviewFrame)+[[self firstSplitView] dividerThickness];
			firstSubviewFrame.size.height = floor(total/2.0);
			secondSubviewFrame.size.height = total-NSHeight(firstSubviewFrame)-[[self firstSplitView] dividerThickness];
		}
		
		[[self view] setFrame:firstSubviewFrame];
		[[[self firstTextViewController] view] setFrame:secondSubviewFrame];
		
		[[self sourceHighlighter] performHighlightingInVisibleRange];
	}
	
	[[[self view] window] makeFirstResponder:[[self firstTextViewController] textView]];
}
- (IBAction)addAssistantEditor:(id)sender {
	[self addAssistantEditorForSourceTextViewController:[self firstTextViewController]];
}
- (IBAction)removeAssistantEditor:(id)sender {
	[self removeAssistantEditorForSourceTextViewController:[_assistantSourceTextViewControllers lastObject]];
}

#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(addAssistantEditor:)) {
		if (![_assistantSplitViews count])
			return NO;
	}
	else if ([menuItem action] == @selector(removeAssistantEditor:)) {
		if ([_assistantSplitViews count] <= 1)
			return NO;
	}
	return YES;
}
#pragma mark NSSplitViewDelegate
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
	if ([splitView isVertical])
		return proposedMaximumPosition-ceil(NSWidth([splitView bounds])/4.0);
	return proposedMaximumPosition-ceil(NSHeight([splitView bounds])/4.0);
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
	if ([splitView isVertical])
		return proposedMinimumPosition+ceil(NSWidth([splitView bounds])/4.0);
	return proposedMinimumPosition+ceil(NSHeight([splitView bounds])/4.0);
}

#pragma mark *** Public Methods ***
- (void)addAssistantEditorForSourceTextViewController:(WCSourceTextViewController *)firstSourceTextViewController; {
	NSView *contentView = [[firstSourceTextViewController view] superview];
	WCSplitView *splitView = [self configuredSplitView];
	WCSourceTextViewController *secondSourceTextViewController = [self configuredSourceTextViewController];
	
	[_assistantSplitViews addObject:splitView];
	[_assistantSourceTextViewControllers addObject:secondSourceTextViewController];
	
	BOOL verticalSplitView = [NSEvent isOptionKeyPressed];
	if (verticalSplitView) {
		[splitView setDividerStyle:NSSplitViewDividerStylePaneSplitter];
		[splitView setVertical:YES];
	}
	else {
		[splitView setDividerStyle:NSSplitViewDividerStyleThin];
		[splitView setVertical:NO];
	}
	
	[splitView setFrame:[contentView frame]];
	[contentView replaceSubview:[firstSourceTextViewController view] with:splitView];
	[splitView addSubview:[firstSourceTextViewController view]];
	[splitView addSubview:[secondSourceTextViewController view]];
	
	NSRect firstSubviewFrame = [[firstSourceTextViewController view] frame];
	NSRect secondSubviewFrame = [[secondSourceTextViewController view] frame];
	CGFloat total;
	
	if (verticalSplitView) {
		total = NSWidth(firstSubviewFrame)+NSWidth(secondSubviewFrame)+[splitView dividerThickness];
		firstSubviewFrame.size.width = floor(total/2.0);
		secondSubviewFrame.size.width = total-NSWidth(firstSubviewFrame)-[splitView dividerThickness];
	}
	else {
		total = NSHeight(firstSubviewFrame)+NSHeight(secondSubviewFrame)+[splitView dividerThickness];
		firstSubviewFrame.size.height = floor(total/2.0);
		secondSubviewFrame.size.height = total-NSHeight(firstSubviewFrame)-[splitView dividerThickness];
	}
	
	[[firstSourceTextViewController view] setFrame:firstSubviewFrame];
	[[secondSourceTextViewController view] setFrame:secondSubviewFrame];
	
	[[self sourceHighlighter] performHighlightingInVisibleRange];
	
	[[[self view] window] makeFirstResponder:[secondSourceTextViewController textView]];
}

- (void)removeAssistantEditorForSourceTextViewController:(WCSourceTextViewController *)sourceTextViewController; {
	if ([_assistantSplitViews count] <= 1) {
		NSBeep();
		return;
	}
	
	NSView *replacementSubview = nil;
	for (NSView *subview in [[[sourceTextViewController view] superview] subviews]) {
		if (subview != [sourceTextViewController view]) {
			replacementSubview = subview;
			break;
		}
	}
	
	NSView *parentView = [replacementSubview superview];
	
	[[sourceTextViewController view] removeFromSuperviewWithoutNeedingDisplay];
	[[parentView superview] replaceSubview:parentView with:replacementSubview];
	
	[_assistantSplitViews removeObject:parentView];
	[[self textStorage] removeLayoutManager:[[sourceTextViewController textView] layoutManager]];
	[_assistantSourceTextViewControllers removeObject:sourceTextViewController];
}
#pragma mark Properties
@dynamic firstSplitView;
- (WCSplitView *)firstSplitView {
	if (![_assistantSplitViews count]) {
		[_assistantSplitViews addObject:[self configuredSplitView]];
	}
	return [_assistantSplitViews firstObject];
}
@dynamic configuredSplitView;
- (WCSplitView *)configuredSplitView {
	WCSplitView *splitView = [[[WCSplitView alloc] initWithFrame:[[self view] frame]] autorelease];
	[splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMinYMargin];
	[splitView setDividerColor:[NSColor darkGrayColor]];
	[splitView setDelegate:self];
	return splitView;
}
@dynamic firstTextViewController;
- (WCSourceTextViewController *)firstTextViewController {
	if (![_assistantSourceTextViewControllers count]) {
		[_assistantSourceTextViewControllers addObject:[self configuredSourceTextViewController]];
	}
	return [_assistantSourceTextViewControllers firstObject];
}
@dynamic configuredSourceTextViewController;
- (WCSourceTextViewController *)configuredSourceTextViewController {
	WCSourceTextViewController *stvController = [[[WCSourceTextViewController alloc] initWithSourceFileDocument:[self sourceFileDocument] standardSourceTextViewController:self] autorelease];
	return stvController;
}
@end
