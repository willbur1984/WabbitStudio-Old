//
//  WCMacroSymbol.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCMacroSymbol.h"

@implementation WCMacroSymbol
- (void)dealloc {
	[_value release];
	[_arguments release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type: %@\nrange: %@\nname: %@\nvalue: %@\narguments: %@",[self typeDescription],NSStringFromRange([self range]),[self name],[self value],[self arguments]];
}

- (NSString *)completionName {
	if ([self arguments])
		return [NSString stringWithFormat:@"%@(%@)",[self name],[[self arguments] componentsJoinedByString:@","]];
	else
		return [self name];
}
- (NSArray *)completionArguments {
	return [self arguments];
}

+ (id)macroSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value arguments:(NSArray *)arguments; {
	return [[[[self class] alloc] initWithRange:range name:name value:value arguments:arguments] autorelease];
}
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value arguments:(NSArray *)arguments; {
	if (!(self = [super initWithType:WCSourceSymbolTypeMacro range:range name:name]))
		return nil;
	
	_value = [value copy];
	_arguments = [arguments copy];
	
	return self;
}

+ (id)macroSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value; {
	return [self macroSymbolWithRange:range name:name value:value arguments:nil];
}

@synthesize value=_value;
@synthesize arguments=_arguments;
@end