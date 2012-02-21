//
//  WCFoldMarker.m
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFoldMarker.h"

@implementation WCFoldMarker
- (NSString *)description {
	return [NSString stringWithFormat:@"type: %d range: %@",[self type],NSStringFromRange([self range])];
}

+ (id)foldMarkerOfType:(WCFoldMarkerType)type range:(NSRange)range; {
	return [[[[self class] alloc] initWithType:type range:range] autorelease];
}
- (id)initWithType:(WCFoldMarkerType)type range:(NSRange)range; {
	if (!(self = [super init]))
		return nil;
	
	_type = type;
	_range = range;
	
	return self;
}

@synthesize type=_type;
@synthesize range=_range;

@end
