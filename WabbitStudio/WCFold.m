//
//  WCFold.m
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFold.h"

@implementation WCFold
- (NSString *)description {
	return [NSString stringWithFormat:@"range: %@ level: %lu",NSStringFromRange([self range]),[self level]];
}

+ (id)foldWithRange:(NSRange)range level:(NSUInteger)level; {
	return [[[[self class] alloc] initWithRange:range level:level] autorelease];
}
- (id)initWithRange:(NSRange)range level:(NSUInteger)level; {
	if (!(self = [super initWithRepresentedObject:nil]))
		return nil;
	
	_range = range;
	_level = level;
	
	return self;
}

@synthesize range=_range;
@synthesize level=_level;

@end
