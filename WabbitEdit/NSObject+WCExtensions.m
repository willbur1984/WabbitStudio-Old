//
//  NSObject+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "NSObject+WCExtensions.h"

NSString *const kUserDefaultsKeyPathPrefix = @"values.";

@implementation NSObject (WCExtensions)
- (void)addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths; {
	for (NSString *keyPath in keyPaths)
		[self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:observer];
}
- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths; {
	for (NSString *keyPath in keyPaths)
		[self removeObserver:observer forKeyPath:keyPath context:observer];
}

- (NSSet *)userDefaultsKeyPathsToObserve; {
	return nil;
}

- (void)setupUserDefaultsObserving; {
	for (NSString *keyPath in [self userDefaultsKeyPathsToObserve])
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[kUserDefaultsKeyPathPrefix stringByAppendingString:keyPath] options:NSKeyValueObservingOptionNew context:self];
}
- (void)cleanUpUserDefaultsObserving; {
	for (NSString *keyPath in [self userDefaultsKeyPathsToObserve])
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[kUserDefaultsKeyPathPrefix stringByAppendingString:keyPath] context:self];
}
@end
