//
//  RSNavigatorControlDataSource.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSNavigatorControl;

@protocol RSNavigatorControlDataSource <NSObject>
@required
- (NSArray *)itemIdentifiersForNavigatorControl:(RSNavigatorControl *)navigatorControl;
- (CGFloat)itemWidthForNavigatorControl:(RSNavigatorControl *)navigatorControl;
- (NSImage *)navigatorControl:(RSNavigatorControl *)navigatorControl imageForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index;
@optional
- (NSSize)navigatorControl:(RSNavigatorControl *)navigatorControl imageSizeForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index;
- (NSString *)navigatorControl:(RSNavigatorControl *)navigatorControl toopTipForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index;
@end
