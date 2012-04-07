//
//  NSUserDefaults+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "NSUserDefaults+RSExtensions.h"

@implementation NSUserDefaults (RSExtensions)
- (unsigned int)unsignedIntForKey:(NSString *)key; {
	return [[self objectForKey:key] unsignedIntValue];
}
- (NSUInteger)unsignedIntegerForKey:(NSString *)key; {
	return [[self objectForKey:key] unsignedIntegerValue];
}
- (int)intForKey:(NSString *)key; {
	return [[self objectForKey:key] intValue];
}

- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key; {
	[self setObject:[NSNumber numberWithUnsignedInteger:value] forKey:key];
}
@end
