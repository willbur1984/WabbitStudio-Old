//
//  WCProjectNavigatorViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectNavigatorViewController.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "WCProjectContainer.h"
#import "RSOutlineView.h"
#import "RSFindOptionsViewController.h"
#import "RSDefines.h"

@interface WCProjectNavigatorViewController ()
@property (readwrite,retain,nonatomic) WCProjectContainer *filteredProjectContainer;
@property (readwrite,assign,nonatomic) BOOL switchTreeControllerContentBinding;
@property (readonly,nonatomic) RSFindOptionsViewController *filterOptionsViewController;
@end

@implementation WCProjectNavigatorViewController
- (void)dealloc {
	[_filterOptionsViewController release];
	[_filterString release];
	[_filteredProjectContainer release];
	[_projectContainer release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCProjectNavigatorView";
}

- (void)loadView {
	[super loadView];
	
	[[[self searchField] cell] setPlaceholderString:NSLocalizedString(@"Filter Files", @"Filter Files")];
	[[[[self searchField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self searchField] cell] searchButtonCell] setAlternateImage:nil];
	
	[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(toggleFilterOptions:)) {
		if ([[self filterOptionsViewController] areFindOptionsVisible])
			[menuItem setTitle:NSLocalizedString(@"Hide Filter Options\u2026", @"hide filter options with ellipsis")];
		else
			[menuItem setTitle:NSLocalizedString(@"Show Filter Options\u2026", @"show filter options with ellipsis")];
	}
	return YES;
}

- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectContainer = [projectContainer retain];
	_projectNavigatorFlags.switchTreeControllerContentBinding = YES;
	
	return self;
}

- (void)findOptionsViewControllerDidChangeFindOptions:(RSFindOptionsViewController *)viewController {
	if ([[self filterString] length])
		[self filter:nil];
}

- (IBAction)filter:(id)sender; {
	if (![[self filterString] length]) {
		[self setSwitchTreeControllerContentBinding:YES];
		[[self treeController] bind:NSContentObjectBinding toObject:self withKeyPath:@"projectContainer" options:nil];
		[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
		[self setFilteredProjectContainer:nil];
		return;
	}
	else if ([self switchTreeControllerContentBinding]) {
		[self setSwitchTreeControllerContentBinding:NO];
		[[self treeController] bind:NSContentObjectBinding toObject:self withKeyPath:@"filteredProjectContainer" options:nil];
	}
	
	WCProjectContainer *filteredProjectContainer = [WCProjectContainer projectContainerWithProject:[[self projectContainer] project]];
	NSArray *leafNodes = [[self projectContainer] descendantLeafNodes];
	NSMutableArray *filteredLeafNodes = [NSMutableArray arrayWithCapacity:[leafNodes count]];
	NSMapTable *parentNodesToFilteredParentNodes = [NSMapTable mapTableWithWeakToStrongObjects];
	NSPredicate *predicate;
	
	[parentNodesToFilteredParentNodes setObject:filteredProjectContainer forKey:[self projectContainer]];
	
	if ([[self filterOptionsViewController] findStyle] == RSFindOptionsFindStyleTextual) {
		switch ([[self filterOptionsViewController] matchStyle]) {
			case RSFindOptionsMatchStyleContains:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName contains %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName contains[c] %@",[self filterString]];
				break;
			case RSFindOptionsMatchStyleStartsWith:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName beginswith %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName beginswith[c] %@",[self filterString]];
				break;
			case RSFindOptionsMatchStyleEndsWith:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName endswith %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName endswith[c] %@",[self filterString]];
				break;
			case RSFindOptionsMatchStyleWholeWord:
				if ([[self filterOptionsViewController] matchCase])
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName like %@",[self filterString]];
				else
					predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName like[c] %@",[self filterString]];
				break;
			default:
				break;
		}
	}
	else {
		if ([[self filterOptionsViewController] matchCase])
			predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName matches %@",[self filterString]];
		else
			predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName matches[c] %@",[self filterString]];
	}
	
	[filteredLeafNodes setArray:[leafNodes filteredArrayUsingPredicate:predicate]];
	
	for (RSTreeNode *leafNode in filteredLeafNodes) {
		RSTreeNode *filteredLeafNode = [RSTreeNode treeNodeWithRepresentedObject:[leafNode representedObject]];
		
		while ([leafNode parentNode]) {
			RSTreeNode *filteredParentNode = [parentNodesToFilteredParentNodes objectForKey:[leafNode parentNode]];
			
			if (filteredParentNode) {
				[[filteredParentNode mutableChildNodes] addObject:filteredLeafNode];
				filteredLeafNode = nil;
				break;
			}
			
			filteredParentNode = [RSTreeNode treeNodeWithRepresentedObject:[[leafNode parentNode] representedObject]];
			[parentNodesToFilteredParentNodes setObject:filteredParentNode forKey:[leafNode parentNode]];
			[[filteredParentNode mutableChildNodes] addObject:filteredLeafNode];
			
			leafNode = [leafNode parentNode];
			filteredLeafNode = filteredParentNode;
		}
		
		if (filteredLeafNode)
			[[filteredProjectContainer mutableChildNodes] addObject:filteredLeafNode];
	}
	
	[self setFilteredProjectContainer:filteredProjectContainer];
	[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:YES];
}

- (IBAction)toggleFilterOptions:(id)sender; {
	if ([[self filterOptionsViewController] areFindOptionsVisible])
		[self hideFilterOptions:nil];
	else
		[self showFilterOptions:nil];
}
- (IBAction)showFilterOptions:(id)sender; {
	NSRect rect = [(NSSearchFieldCell *)[[self searchField] cell] searchButtonRectForBounds:[[self searchField] bounds]];
	[[self filterOptionsViewController] showFindOptionsViewRelativeToRect:rect ofView:[self searchField] preferredEdge:NSMaxYEdge];
}
- (IBAction)hideFilterOptions:(id)sender; {
	[[self filterOptionsViewController] hideFindOptionsView];
}

@synthesize outlineView=_outlineView;
@synthesize searchField=_searchField;
@synthesize treeController=_treeController;

@synthesize projectContainer=_projectContainer;
@synthesize filteredProjectContainer=_filteredProjectContainer;
@synthesize filterString=_filterString;
@dynamic switchTreeControllerContentBinding;
- (BOOL)switchTreeControllerContentBinding {
	return _projectNavigatorFlags.switchTreeControllerContentBinding;
}
- (void)setSwitchTreeControllerContentBinding:(BOOL)switchTreeControllerContentBinding {
	_projectNavigatorFlags.switchTreeControllerContentBinding = switchTreeControllerContentBinding;
}
@dynamic filterOptionsViewController;
- (RSFindOptionsViewController *)filterOptionsViewController {
	if (!_filterOptionsViewController) {
		_filterOptionsViewController = [[RSFindOptionsViewController alloc] init];
		[_filterOptionsViewController setRegexOptionsEnabled:NO];
		[_filterOptionsViewController setWrapAround:NO];
		[_filterOptionsViewController setWrapAroundEnabled:NO];
		[_filterOptionsViewController setDelegate:self];
	}
	return _filterOptionsViewController;
}

@end
