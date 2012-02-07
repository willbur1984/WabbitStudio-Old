//
//  WCInterfacePerformer.h
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCGroupContainer;

@interface WCInterfacePerformer : NSObject
+ (WCInterfacePerformer *)sharedPerformer;

- (BOOL)addFileURLs:(NSArray *)fileURLs toGroupContainer:(WCGroupContainer *)groupContainer error:(NSError **)outError;
- (BOOL)addFileURLs:(NSArray *)fileURLs toGroupContainer:(WCGroupContainer *)groupContainer atIndex:(NSUInteger)index error:(NSError **)outError;
- (BOOL)addFileURLs:(NSArray *)fileURLs toGroupContainer:(WCGroupContainer *)groupContainer atIndex:(NSUInteger)index copyFiles:(BOOL)copyFiles error:(NSError **)outError;
@end
