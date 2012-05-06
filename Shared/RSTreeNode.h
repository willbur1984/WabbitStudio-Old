//
//  RSTreeNode.h
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

#import "RSObject.h"
#import <Quartz/Quartz.h>

extern NSString *const RSTreeNodeChildNodesKey;

/** Base class for tree objects. Modeled after NSTreeNode.
 
 Meant to be used as a container for model objects that should have no knowledge of their place in the corresponding tree structure.
 
 */

@interface RSTreeNode : RSObject <RSPlistArchiving,NSCopying,NSMutableCopying,QLPreviewItem> {
	__weak id _parentNode;
	NSMutableArray *_childNodes;
	id _representedObject;
}
@property (readonly,assign,nonatomic) id parentNode;
@property (readonly,nonatomic) NSArray *childNodes;
@property (readonly,nonatomic) NSMutableArray *mutableChildNodes;

@property (readwrite,retain,nonatomic) id representedObject;
@property (readonly,nonatomic,getter = isLeafNode) BOOL leafNode;
@property (readonly,nonatomic) NSIndexPath *indexPath;

@property (readonly,nonatomic) NSArray *descendantNodes;
@property (readonly,nonatomic) NSArray *descendantNodesInclusive;
@property (readonly,nonatomic) NSArray *descendantLeafNodes;
@property (readonly,nonatomic) NSArray *descendantLeafNodesInclusive;
@property (readonly,nonatomic) NSArray *descendantGroupNodes;
@property (readonly,nonatomic) NSArray *descendantGroupNodesInclusive;

- (BOOL)isDescendantOfNode:(RSTreeNode *)node;

- (void)sortWithSortDescriptors:(NSArray *)sortDescriptors recursively:(BOOL)recursively;

+ (id)treeNodeWithRepresentedObject:(id)representedObject;
- (id)initWithRepresentedObject:(id)representedObject;
@end
