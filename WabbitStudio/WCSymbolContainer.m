//
//  WCSymbolContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSymbolContainer.h"

@implementation WCSymbolContainer
- (BOOL)isLeafNode {
	return YES;
}

+ (id)symbolContainerWithSourceSymbol:(WCSourceSymbol *)sourceSymbol; {
	return [[[[self class] alloc] initWithSourceSymbol:sourceSymbol] autorelease];
}
- (id)initWithSourceSymbol:(WCSourceSymbol *)sourceSymbol; {
	if (!(self = [super initWithRepresentedObject:sourceSymbol]))
		return nil;
	
	return self;
}
@end
