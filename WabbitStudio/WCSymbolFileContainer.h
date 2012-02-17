//
//  WCSymbolFileContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCFile;

@interface WCSymbolFileContainer : RSTreeNode
@property (readonly,nonatomic) NSString *statusString;

+ (id)symbolFileContainerWithFile:(WCFile *)file;
- (id)initWithFile:(WCFile *)file;
@end
