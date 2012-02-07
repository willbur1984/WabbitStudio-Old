//
//  WCSearchNavigatorViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSearchNavigatorViewController.h"
#import "NSTreeController+RSExtensions.h"
#import "WCProjectContainer.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "WCSearchContainer.h"

@implementation WCSearchNavigatorViewController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_filteredSearchContainer release];
	[_searchContainer release];
	[_projectContainer release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"WCSearchNavigatorView";
}

- (void)loadView {
	[super loadView];
	
	[[[self filterField] cell] setPlaceholderString:NSLocalizedString(@"Filter Search Results", @"Filter Search Results")];
	[[[[self filterField] cell] searchButtonCell] setImage:[NSImage imageNamed:@"Filter"]];
	[[[[self filterField] cell] searchButtonCell] setAlternateImage:nil];
}
#pragma mark NSOutlineViewDelegate
static NSString *const kProjectCellIdentifier = @"ProjectCell";
static NSString *const kMainCellIdentifier = @"MainCell";
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	id file = [[item representedObject] representedObject];
	
	if ([file isKindOfClass:[WCProject class]])
		return [outlineView makeViewWithIdentifier:kProjectCellIdentifier owner:self];
	return [outlineView makeViewWithIdentifier:kMainCellIdentifier owner:self];
}

static const CGFloat kProjectCellHeight = 30.0;
static const CGFloat kMainCellHeight = 18.0;
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
	id file = [[item representedObject] representedObject];
	
	if ([file isKindOfClass:[WCProject class]])
		return kProjectCellHeight;
	return kMainCellHeight;
}
#pragma mark WCNavigatorModule
- (NSArray *)selectedObjects {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	NSMutableArray *retval = [NSMutableArray array];
	if (clickedRow == -1 || [[[self outlineView] selectedRowIndexes] containsIndex:clickedRow]) {
		[retval addObjectsFromArray:[[self treeController] selectedRepresentedObjects]];
	}
	else {
		id clickedFile = [[[self outlineView] itemAtRow:clickedRow] representedObject];
		
		[retval addObject:clickedFile];
	}
	return retval;
}
- (void)setSelectedObjects:(NSArray *)objects {
	[[self treeController] setSelectedRepresentedObjects:objects];
}
- (NSArray *)selectedModelObjects; {
	NSInteger clickedRow = [[self outlineView] clickedRow];
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[[[self outlineView] selectedRowIndexes] count]];
	
	if (clickedRow == -1 || [[[self outlineView] selectedRowIndexes] containsIndex:clickedRow]) {
		[retval addObjectsFromArray:[[self treeController] selectedModelObjects]];
	}
	else {
		id clickedModelObject = [[[[self outlineView] itemAtRow:clickedRow] representedObject] representedObject];
		
		[retval addObject:clickedModelObject];
	}
	
	return [[retval copy] autorelease];
}
- (void)setSelectedModelObjects:(NSArray *)modelObjects; {
	[[self treeController] setSelectedModelObjects:modelObjects];
}

- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectContainer = [projectContainer retain];
	_searchContainer = [[WCSearchContainer alloc] initWithProject:[_projectContainer project]];
	
	return self;
}

@synthesize outlineView=_outlineView;
@synthesize treeController=_treeController;
@synthesize searchField=_searchField;
@synthesize filterField=_filterField;

@synthesize searchContainer=_searchContainer;
@synthesize filteredSearchContainer=_filteredSearchContainer;

@end
