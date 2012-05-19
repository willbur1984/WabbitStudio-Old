//
//  NSTreeController+WCExtensions.h
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

- (id)selectedModelObject;
- (NSArray *)selectedModelObjects;
- (void)setSelectedModelObject:(id)modelObject;
- (void)setSelectedModelObjects:(NSArray *)modelObjects;

- (id)treeNodeForModelObject:(id)modelObject;
- (NSArray *)treeNodesForModelObjects:(NSArray *)modelObjects;
- (NSArray *)representedObjectsForModelObjects:(NSArray *)modelObjects;

@end
