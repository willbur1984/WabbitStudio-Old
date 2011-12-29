//
//  WCNumberToken.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCNumberToken.h"

@implementation WCNumberToken
- (id)initWithType:(WCSourceTokenType)type range:(NSRange)range name:(NSString *)name {
	if (!(self = [super initWithType:type range:range name:name]))
		return nil;
	
	_value = NSIntegerMax;
	
	return self;
}

@dynamic value;
- (NSInteger)value {
	if (_value == NSIntegerMax) {
		
	}
	return _value;
}
@end
