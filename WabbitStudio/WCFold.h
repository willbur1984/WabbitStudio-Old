//
//  WCFold.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@interface WCFold : RSTreeNode {
	NSRange _range;
	NSUInteger _level;
}
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSUInteger level;

+ (id)foldWithRange:(NSRange)range level:(NSUInteger)level;
- (id)initWithRange:(NSRange)range level:(NSUInteger)level;
@end
