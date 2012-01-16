//
//  RSTreeNode.h
//  WabbitStudio
//
//  Created by William Towe on 1/10/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"
#import <Quartz/Quartz.h>

extern NSString *const RSTreeNodeChildNodesKey;

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

+ (id)treeNodeWithRepresentedObject:(id)representedObject;
- (id)initWithRepresentedObject:(id)representedObject;
@end
