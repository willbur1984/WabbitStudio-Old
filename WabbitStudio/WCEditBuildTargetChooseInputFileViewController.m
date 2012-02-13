//
//  WCEditBuildTargetChooseInputFileViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetChooseInputFileViewController.h"
#import "WCEditBuildTargetWindowController.h"
#import "WCFile.h"
#import "NSTreeController+RSExtensions.h"
#import "WCBuildTarget.h"

@implementation WCEditBuildTargetChooseInputFileViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_editBuildTargetWindowController = nil;
	[_popover release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCEditBuildTargetChooseInputFileView";
}

- (void)loadView {
	[super loadView];
	
	[[self outlineView] setTarget:self];
	[[self outlineView] setDoubleAction:@selector(_outlineViewDoubleClick:)];
	
	[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
	
	[[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"Filter Files", @"Filter Files")];
	[[[[self searchField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self searchField] cell] searchButtonCell] setAlternateImage:nil];
	
	if ([[[self editBuildTargetWindowController] buildTarget] inputFile])
		[[self treeController] setSelectedModelObject:[[[self editBuildTargetWindowController] buildTarget] inputFile]];
}

- (void)popoverDidClose:(NSNotification *)notification {
	[self autorelease];
	
	[_popover setContentViewController:nil];
}

+ (id)editBuildTargetChooseInputFileViewControllerWithEditBuildTargetWindowController:(WCEditBuildTargetWindowController *)editBuildTargetWindowController; {
	return [[[[self class] alloc] initWithEditBuildTargetWindowController:editBuildTargetWindowController] autorelease];
}
- (id)initWithEditBuildTargetWindowController:(WCEditBuildTargetWindowController *)editBuildTargetWindowController; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_editBuildTargetWindowController = editBuildTargetWindowController;
	_popover = [[NSPopover alloc] init];
	[_popover setBehavior:NSPopoverBehaviorApplicationDefined];
	[_popover setDelegate:self];
	
	return self;
}

- (void)showChooseInputFileViewRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge; {
	[self retain];
	
	[_popover setContentViewController:self];
	[_popover showRelativeToRect:rect ofView:view preferredEdge:preferredEdge];
}
- (void)hideChooseInputFileView; {
	[_popover performClose:nil];
}

- (IBAction)ok:(id)sender; {
	[self hideChooseInputFileView];
	
	WCFile *selectedFile = [[[self treeController] selectedModelObjects] lastObject];
	
	[[[self editBuildTargetWindowController] buildTarget] setInputFile:selectedFile];
}
- (IBAction)cancel:(id)sender; {
	[self hideChooseInputFileView];
}

@synthesize outlineView=_outlineView;
@synthesize searchField=_searchField;
@synthesize treeController=_treeController;

@synthesize editBuildTargetWindowController=_editBuildTargetWindowController;

- (IBAction)_outlineViewDoubleClick:(id)sender; {
	[self ok:nil];
}

@end
