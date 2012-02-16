//
//  WCBuildIssueContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCBuildIssue;

@interface WCBuildIssueContainer : RSTreeNode
+ (id)buildIssueContainerWithBuildIssue:(WCBuildIssue *)buildIssue;
- (id)initWithBuildIssue:(WCBuildIssue *)buildIssue;
@end
