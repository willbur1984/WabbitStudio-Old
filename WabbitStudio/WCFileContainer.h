//
//  WCFileContainer.h
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"
#import "WCFileDelegate.h"

@class WCFile,WCProject;

@interface WCFileContainer : RSTreeNode <WCFileDelegate>

@property (readonly,nonatomic) WCFile *file;
@property (readonly,nonatomic) WCProject *project;

+ (WCFileContainer *)fileContainerWithFile:(WCFile *)file;
- (id)initWithFile:(WCFile *)file;
@end
