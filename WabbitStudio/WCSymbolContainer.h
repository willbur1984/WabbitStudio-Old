//
//  WCSymbolContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCSourceSymbol;

@interface WCSymbolContainer : RSTreeNode
+ (id)symbolContainerWithSourceSymbol:(WCSourceSymbol *)sourceSymbol;
- (id)initWithSourceSymbol:(WCSourceSymbol *)sourceSymbol;
@end
