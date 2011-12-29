//
//  WCEquateSymbol.m
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCEquateSymbol.h"

@implementation WCEquateSymbol
- (void)dealloc {
	[_value release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@\nvalue: %@",[self typeDescription],NSStringFromRange([self range]),[self name],[self value]];
}

- (NSString *)completionName {
	return [NSString stringWithFormat:@"%@ = %@",[self name],[self value]];
}

+ (id)equateSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value; {
	return [[[[self class] alloc] initWithRange:range name:name value:value] autorelease];
}
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value; {
	if (!(self = [super initWithType:WCSourceSymbolTypeEquate range:range name:name]))
		return nil;
	
	_value = [value copy];
	
	return self;
}

@synthesize value=_value;
@end
