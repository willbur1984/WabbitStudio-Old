//
//  WCStandardSourceTextViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/10/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCStandardSourceTextViewController.h"
#import "WCSplitView.h"
#import "NSArray+WCExtensions.h"
#import "WCSourceTextView.h"
#import "NSEvent+RSExtensions.h"
#import "WCSourceHighlighter.h"
#import "WCSourceTextStorage.h"
#import "RSDefines.h"
#import "WCJumpBarViewController.h"
#import "WCSourceScanner.h"
#import "WCSourceFileDocument.h"
#import "RSFindBarFieldEditor.h"
#import "RSFindBarViewController.h"
#import "WCJumpBar.h"

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

- (void)loadView {
	[super loadView];
	
	CGFloat delta = 0.0;
	
	delta += [[[self jumpBarViewController] addAssistantEditorButton] frame].size.width;
	delta += [[[self jumpBarViewController] removeAssistantEditorButton] frame].size.width;
	delta += [[[self jumpBarViewController] rightVerticalSeparator] frame].size.width;
	delta += 12.0;
	
	[[[self jumpBarViewController] addAssistantEditorButton] removeFromSuperview];
	[[[self jumpBarViewController] removeAssistantEditorButton] removeFromSuperview];
	[[[self jumpBarViewController] rightVerticalSeparator] removeFromSuperview];
	
	NSSize size = [[[self jumpBarViewController] jumpBar] frame].size;
	
	size.width += delta;
	
	[[[self jumpBarViewController] jumpBar] setFrameSize:size];
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
			[controller performCleanup];
		
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
		
		//[[self sourceHighlighter] highlightSymbolsInVisibleRange];
		
		[[[self firstTextViewController] textView] setSelectedRange:[[self textView] selectedRange]];
		[[[self firstTextViewController] textView] scrollRangeToVisible:[[[self firstTextViewController] textView] selectedRange]];
	}
	
	[[[self view] window] makeFirstResponder:[[self firstTextViewController] textView]];
}
- (IBAction)addAssistantEditor:(id)sender {
	[self addAssistantEditorForSourceTextViewController:[self firstTextViewController]];
}
- (IBAction)removeAssistantEditor:(id)sender {
	[self removeAssistantEditorForSourceTextViewController:[_assistantSourceTextViewControllers lastObject]];
}

- (IBAction)moveFocusToNextArea:(id)sender; {
	NSResponder *firstResponder = [[[self view] window] firstResponder];
	// make the first assistant editor first responder
	if (firstResponder == [self textView]) {
		[[[self view] window] makeFirstResponder:[[self firstTextViewController] textView]];
	}
	else {
		__block NSUInteger controllerIndex = NSNotFound;
		
		[_assistantSourceTextViewControllers enumerateObjectsUsingBlock:^(WCSourceTextViewController *stvController, NSUInteger index, BOOL *stop) {
			if (firstResponder == [stvController textView]) {
				controllerIndex = index;
				*stop = YES;
			}
		}];
		
		if (controllerIndex == NSNotFound)
			return;
		else if (controllerIndex < [_assistantSourceTextViewControllers count])
			controllerIndex++;
		
		if (controllerIndex == [_assistantSourceTextViewControllers count])
			controllerIndex = 0;
		
		WCSourceTextViewController *stvController = [_assistantSourceTextViewControllers objectAtIndex:controllerIndex];
		
		[[[self view] window] makeFirstResponder:[stvController textView]];
	}
}
- (IBAction)moveFocusToPreviousArea:(id)sender; {
	
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
    else if ([menuItem action] == @selector(showStandardEditor:))
        return YES;
    else if ([menuItem action] == @selector(showAssistantEditor:))
        return YES;
	return [super validateMenuItem:menuItem];
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
	[_assistantSourceTextViewControllers insertObject:secondSourceTextViewController atIndex:[_assistantSourceTextViewControllers indexOfObjectIdenticalTo:firstSourceTextViewController]];
	
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
	
	//[[self sourceHighlighter] highlightSymbolsInVisibleRange];
	
	[[secondSourceTextViewController textView] setSelectedRange:[[firstSourceTextViewController textView] selectedRange]];
	[[secondSourceTextViewController textView] scrollRangeToVisible:[[secondSourceTextViewController textView] selectedRange]];
	
	[[[self view] window] makeFirstResponder:[secondSourceTextViewController textView]];
}

- (void)removeAssistantEditorForSourceTextViewController:(WCSourceTextViewController *)sourceTextViewController; {
	if ([_assistantSplitViews count] <= 1) {
		[self showStandardEditor:nil];
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
	[sourceTextViewController performCleanup];
	[_assistantSourceTextViewControllers removeObject:sourceTextViewController];
}

- (void)performCleanup; {
	[super performCleanup];
	
	for (WCSourceTextViewController *stvController in _assistantSourceTextViewControllers)
		[stvController performCleanup];
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
