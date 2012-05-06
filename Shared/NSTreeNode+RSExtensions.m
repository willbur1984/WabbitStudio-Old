//
//  NSTreeNode+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 4/5/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSTreeNode+RSExtensions.h"


@implementation NSTreeNode (NSTreeNode_WCExtensions)
- (NSArray *)descendantNodes; {
	NSMutableArray *retval = [NSMutableArray array];
	
	for (NSTreeNode *node in [self childNodes]) {
		[retval addObject:node];
		
		if (![node isLeaf])
			[retval addObjectsFromArray:[node descendantNodes]];
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)descendantNodesInclusive; {
	return [[self descendantNodes] arrayByAddingObject:self];
}
- (NSArray *)descendantLeafNodes; {
	NSMutableArray *retval = [NSMutableArray array];
	
	for (NSTreeNode *node in [self childNodes]) {
		if ([node isLeaf])
			[retval addObject:node];
		else
			[retval addObjectsFromArray:[node descendantLeafNodes]];
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)descendantLeafNodesInclusive; {
	if ([self isLeaf])
		return [NSArray arrayWithObject:self];
	return [self descendantLeafNodes];
}
- (NSArray *)descendantGroupNodes; {
	NSMutableArray *retval = [NSMutableArray array];
	
	for (NSTreeNode *node in [self childNodes]) {
		if (![node isLeaf]) {
			[retval addObject:node];
			[retval addObjectsFromArray:[node descendantGroupNodes]];
		}
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)descendantGroupNodesInclusive; {
	if (![self isLeaf])
		return [[NSArray arrayWithObject:self] arrayByAddingObjectsFromArray:[self descendantGroupNodes]];
	return [NSArray array];
}

- (BOOL)isDescendantOfNode:(NSTreeNode *)node; {
	return [[node descendantNodes] containsObject:self];
}
@end
