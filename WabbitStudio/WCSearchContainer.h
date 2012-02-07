//
//  WCSearchContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCProject;

@interface WCSearchContainer : RSTreeNode
@property (readonly,nonatomic) NSString *searchStatus;

+ (id)searchContainerWithProject:(WCProject *)project;
- (id)initWithProject:(WCProject *)project;
@end
