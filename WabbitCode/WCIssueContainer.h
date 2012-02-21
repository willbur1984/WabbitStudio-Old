//
//  WCIssueContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCFile;

@interface WCIssueContainer : RSTreeNode
@property (readonly,nonatomic) NSString *statusString;

+ (id)issueContainerWithFile:(WCFile *)file;
- (id)initWithFile:(WCFile *)file;
@end
