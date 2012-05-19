//
//  NSTreeController+WCExtensions.m
//  files
//
//  Created by William Towe on 5/4/09.
//  Copyright 2009 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSTreeController+RSExtensions.h"
#import "NSArray+WCExtensions.h"
#import "NSTreeNode+RSExtensions.h"
//#import "AIArrayAdditions.h"


@implementation NSTreeController (NSTreeController_WCExtensions)
// returns the root node, or the first object in the root array
- (NSTreeNode *)rootNode; {
	return [[self rootNodes] firstObject];
}
// returns an array of top level nodes
- (NSArray *)rootNodes; {
	return [[self arrangedObjects] childNodes];
}
// returns an array of all the NSTreeNode objects maintained by the receiver
- (NSArray *)treeNodes; {
	NSMutableArray *nodes = [NSMutableArray array];
	
	for (NSTreeNode *node in [self rootNodes]) {
		[nodes addObject:node];
		if (![node isLeaf])
			[nodes addObjectsFromArray:[node descendantNodes]];
	}
	return [[nodes copy] autorelease];
}
// returns the selected NSTreeNode object, or if multiple selection is enabled, the first selected NSTreeNode object
- (NSTreeNode *)selectedNode; {
	return [[self selectedNodes] firstObject];
}
// returns the real model object from the above method
- (id)selectedRepresentedObject; {
	return [[self selectedNode] representedObject];
}
// returns the array of selected real model objects
- (NSArray *)selectedRepresentedObjects; {
	return [[self selectedNodes] valueForKey:@"representedObject"];
}
// returns the corresponding NSTreeNode for 'indexPath'
- (NSTreeNode *)treeNodeAtIndexPath:(NSIndexPath *)indexPath; {
	return [[self arrangedObjects] descendantNodeAtIndexPath:indexPath];
}
// returns an array of NSTreeNode objects given an array of NSIndexPath objects 'indexPaths'
- (NSArray *)treeNodesAtIndexPaths:(NSArray *)indexPaths; {
	NSMutableArray *retval = [NSMutableArray array];
	for (NSIndexPath *indexPath in indexPaths) {
		NSTreeNode *node = [self treeNodeAtIndexPath:indexPath];
		if (node)
			[retval addObject:node];
	}
	return [[retval copy] autorelease];
}
// returns the NSIndexPath for the real model object 'representedObject'
- (NSIndexPath *)indexPathForRepresentedObject:(id)representedObject; {
	for (NSTreeNode *node in [self treeNodes]) {
		if ([representedObject isEqual:[node representedObject]])
			return [node indexPath];
	}
	return nil;
}
// returns an array of NSIndexPath objects given an array of real model objects 'representedObjects'
- (NSArray *)indexPathsForRepresentedObjects:(NSArray *)representedObjects; {
	NSMutableArray *indexPaths = [NSMutableArray array];
	NSArray *nodes = [self treeNodes];
	
	for (id representedObject in representedObjects) {
		for (NSTreeNode *node in nodes) {
			if ([representedObject isEqual:[node representedObject]]) {
				[indexPaths addObject:[node indexPath]];
				break;
			}
		}
	}
	return [[indexPaths copy] autorelease];
}
// returns the corresponding NSTreeNode object for the real model object 'representedObject'
- (NSTreeNode *)treeNodeForRepresentedObject:(id)representedObject; {
	for (NSTreeNode *node in [self treeNodes]) {
		if ([representedObject isEqual:[node representedObject]])
			return node;
	}
	return nil;
}
// returns an array of corresponding NSTreeNode objects for the array of real model objects 'representedObjects'
- (NSArray *)treeNodesForRepresentedObjects:(NSArray *)representedObjects; {
	NSMutableArray *treeNodes = [NSMutableArray array];
	NSArray *nodes = [self treeNodes];
	
	for (id representedObject in representedObjects) {
		for (NSTreeNode *node in nodes) {
			if ([representedObject isEqual:[node representedObject]]) {
				[treeNodes addObject:node];
				break;
			}
		}
	}
	return [[treeNodes copy] autorelease];
}
// selects 'treeNode' using its index path
- (void)setSelectedTreeNode:(NSTreeNode *)treeNode; {
	[self setSelectedTreeNodes:[NSArray arrayWithObject:treeNode]];
}
// selects an array of NSTreeNode objects 'treeNodes' using their index paths
- (void)setSelectedTreeNodes:(NSArray *)treeNodes; {
	[self setSelectionIndexPaths:[treeNodes valueForKey:@"indexPath"]];
}
// selects the real model object 'representedObject'
- (void)setSelectedRepresentedObject:(id)representedObject; {
	[self setSelectedRepresentedObjects:[NSArray arrayWithObject:representedObject]];
}
// selects an array of real model objects 'representedObjects'
- (void)setSelectedRepresentedObjects:(NSArray *)representedObjects; {
	NSMutableArray *indexPaths = [NSMutableArray array];
	NSArray *nodes = [self treeNodes];
	
	for (id representedObject in representedObjects) {
		for (NSTreeNode *node in nodes) {
			if ([representedObject isEqual:[node representedObject]]) {
				[indexPaths addObject:[node indexPath]];
				break;
			}
		}
	}
	[self setSelectionIndexPaths:indexPaths];
}

- (id)selectedModelObject; {
	return [[self selectedModelObjects] firstObject];
}
- (NSArray *)selectedModelObjects; {
	return [[self selectedNodes] valueForKeyPath:@"representedObject.representedObject"];
}
- (void)setSelectedModelObject:(id)modelObject; {
	[self setSelectedModelObjects:[NSArray arrayWithObject:modelObject]];
}
- (void)setSelectedModelObjects:(NSArray *)modelObjects; {
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[modelObjects count]];
	NSArray *treeNodes = [self treeNodes];
	
	for (id modelObject in modelObjects) {
		for (NSTreeNode *treeNode in treeNodes) {
			if ([[treeNode representedObject] representedObject] == modelObject) {
				[indexPaths addObject:[treeNode indexPath]];
				break;
			}
		}
	}
	
	[self setSelectionIndexPaths:indexPaths];
}

- (id)treeNodeForModelObject:(id)modelObject; {
	return [[self treeNodesForModelObjects:[NSArray arrayWithObjects:modelObject, nil]] lastObject];
}
- (NSArray *)treeNodesForModelObjects:(NSArray *)modelObjects; {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[modelObjects count]];
	NSArray *treeNodes = [self treeNodes];
	
	for (id modelObject in modelObjects) {
		for (NSTreeNode *treeNode in treeNodes) {
			if ([[treeNode representedObject] representedObject] == modelObject) {
				[retval addObject:treeNode];
				break;
			}
		}
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)representedObjectsForModelObjects:(NSArray *)modelObjects; {
	return [[self treeNodesForModelObjects:modelObjects] valueForKey:@"representedObject"];
}
@end
