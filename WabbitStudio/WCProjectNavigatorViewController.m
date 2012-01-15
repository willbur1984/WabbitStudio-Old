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

@interface WCProjectNavigatorViewController ()
@property (readonly,nonatomic) WCProjectContainer *filteredProjectContainer;
@end

@implementation WCProjectNavigatorViewController
- (void)dealloc {
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

- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectContainer = [projectContainer retain];
	_filteredProjectContainer = [[WCProjectContainer alloc] initWithProject:[[self projectContainer] project]];
	
	return self;
}

- (IBAction)filter:(id)sender; {
	if (![[self filterString] length]) {
		[[self treeController] bind:NSContentObjectBinding toObject:self withKeyPath:@"projectContainer" options:nil];
		[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:NO];
		return;
	}
	
	[[[self filteredProjectContainer] mutableChildNodes] setArray:nil];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"representedObject.fileName contains[cd] %@",[self filterString]];
	NSArray *filteredLeafNodes = [[[self projectContainer] descendantLeafNodes] filteredArrayUsingPredicate:predicate];
	NSMapTable *parentNodesToFilteredParentNodes = [NSMapTable mapTableWithWeakToStrongObjects];
	
	[parentNodesToFilteredParentNodes setObject:[self filteredProjectContainer] forKey:[self projectContainer]];
	
	for (RSTreeNode *leafNode in filteredLeafNodes) {
		if ([parentNodesToFilteredParentNodes objectForKey:[leafNode parentNode]])
			[[[parentNodesToFilteredParentNodes objectForKey:[leafNode parentNode]] mutableChildNodes] addObject:[RSTreeNode treeNodeWithRepresentedObject:[leafNode representedObject]]];
		else {
			RSTreeNode *originalLeafNode = leafNode;
			RSTreeNode *filteredLeafNode = [RSTreeNode treeNodeWithRepresentedObject:[leafNode representedObject]];
			
			while ([originalLeafNode parentNode] && ![parentNodesToFilteredParentNodes objectForKey:[originalLeafNode parentNode]]) {
				RSTreeNode *filteredParentNode = [RSTreeNode treeNodeWithRepresentedObject:[[originalLeafNode parentNode] representedObject]];
				
				[parentNodesToFilteredParentNodes setObject:filteredParentNode forKey:[originalLeafNode parentNode]];
				[[filteredParentNode mutableChildNodes] addObject:filteredLeafNode];
				
				originalLeafNode = [originalLeafNode parentNode];
				filteredLeafNode = filteredParentNode;
			}
			
			[[[self filteredProjectContainer] mutableChildNodes] addObject:filteredLeafNode];
		}
	}
	
	[[self treeController] bind:NSContentObjectBinding toObject:self withKeyPath:@"filteredProjectContainer" options:nil];
	[[self outlineView] expandItem:[[self outlineView] itemAtRow:0] expandChildren:YES];
}

@synthesize outlineView=_outlineView;
@synthesize searchField=_searchField;
@synthesize treeController=_treeController;

@synthesize projectContainer=_projectContainer;
@synthesize filteredProjectContainer=_filteredProjectContainer;
@synthesize filterString=_filterString;

@end
