//
//  WCBreakpointContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCSourceSymbol,WCFileBreakpoint;

@interface WCBreakpointContainer : RSTreeNode {
	WCSourceSymbol *_symbol;
	NSString *_name;
}
@property (readonly,nonatomic) WCSourceSymbol *symbol;
@property (readonly,nonatomic) NSString *name;

+ (id)breakpointContainerWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;
- (id)initWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;

@end
