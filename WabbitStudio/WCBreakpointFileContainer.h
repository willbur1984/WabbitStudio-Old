//
//  WCBreakpointFileContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCFile;

@interface WCBreakpointFileContainer : RSTreeNode
+ (id)breakpointFileContainerWithFile:(WCFile *)file;
- (id)initWithFile:(WCFile *)file;

@property (readonly,nonatomic) NSString *statusString;
@end
