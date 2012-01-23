//
//  NSTreeController+WCExtensions.h
//  files
//
//  Created by William Towe on 5/4/09.
//  Copyright 2009 Revolution Software. All rights reserved.
//

#import <AppKit/NSTreeController.h>


@interface NSTreeController (NSTreeController_WCExtensions)
- (NSTreeNode *)rootNode;
- (NSArray *)rootNodes;
- (NSArray *)treeNodes;

- (NSTreeNode *)selectedNode;
- (id)selectedRepresentedObject;

- (NSArray *)selectedRepresentedObjects;

- (NSTreeNode *)treeNodeAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)treeNodesAtIndexPaths:(NSArray *)indexPaths;

- (NSIndexPath *)indexPathForRepresentedObject:(id)representedObject;
- (NSArray *)indexPathsForRepresentedObjects:(NSArray *)representedObjects;
- (NSTreeNode *)treeNodeForRepresentedObject:(id)representedObject;
- (NSArray *)treeNodesForRepresentedObjects:(NSArray *)representedObjects;

- (void)setSelectedTreeNode:(NSTreeNode *)treeNode;
- (void)setSelectedTreeNodes:(NSArray *)treeNodes;
- (void)setSelectedRepresentedObject:(id)representedObject;
- (void)setSelectedRepresentedObjects:(NSArray *)representedObjects;

- (NSArray *)selectedModelObjects;
- (void)setSelectedModelObjects:(NSArray *)modelObjects;

- (NSArray *)treeNodesForModelObjects:(NSArray *)modelObjects;
- (NSArray *)representedObjectsForModelObjects:(NSArray *)modelObjects;

@end
