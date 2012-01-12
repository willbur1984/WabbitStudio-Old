//
//  NSObject+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

extern NSString *const kUserDefaultsKeyPathPrefix;

@interface NSObject (WCExtensions)
- (void)addObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths;
- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths;

- (NSSet *)userDefaultsKeyPathsToObserve;
- (void)setupUserDefaultsObserving;
- (void)cleanUpUserDefaultsObserving;
@end
