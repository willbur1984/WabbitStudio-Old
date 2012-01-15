//
//  RSNavigatorControlDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class RSNavigatorControl;

@protocol RSNavigatorControlDelegate <NSObject>
@required
- (NSView *)navigatorControl:(RSNavigatorControl *)navigatorControl contentViewForItemIdentifier:(NSString *)itemIdentifier atIndex:(NSUInteger)index;
@optional
- (void)navigatorControlSelectedItemIdentifierDidChange:(RSNavigatorControl *)navigatorControl;
@end
