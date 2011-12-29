//
//  NSObject+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSObject+WCExtensions.h"

@implementation NSObject (WCExtensions)
- (void)addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths; {
	for (NSString *keyPath in keyPaths)
		[self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:observer];
}
- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths; {
	for (NSString *keyPath in keyPaths)
		[self removeObserver:observer forKeyPath:keyPath context:observer];
}
@end
