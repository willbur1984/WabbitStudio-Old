//
//  NSUserDefaults+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSUserDefaults.h>

@interface NSUserDefaults (RSExtensions)
- (unsigned int)unsignedIntForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;

- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key;
@end
