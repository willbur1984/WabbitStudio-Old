//
//  NSUserDefaults+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
