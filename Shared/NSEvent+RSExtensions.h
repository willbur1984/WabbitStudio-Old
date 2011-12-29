//
//  NSEvent+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 7/12/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSEvent.h>

@interface NSEvent (NSEvent_RSExtensions)
- (BOOL)isCommandKeyPressed;
- (BOOL)isOptionKeyPressed;
- (BOOL)isControlKeyPressed;
- (BOOL)isShiftKeyPressed;

- (BOOL)isOnlyCommandKeyPressed;
- (BOOL)isOnlyOptionKeyPressed;
- (BOOL)isOnlyControlKeyPressed;
- (BOOL)isOnlyShiftKeyPressed;

+ (BOOL)isCommandKeyPressed;
+ (BOOL)isOptionKeyPressed;
+ (BOOL)isControlKeyPressed;
+ (BOOL)isShiftKeyPressed;

+ (BOOL)isOnlyCommandKeyPressed;
+ (BOOL)isOnlyOptionKeyPressed;
+ (BOOL)isOnlyControlKeyPressed;
+ (BOOL)isOnlyShiftKeyPressed;
@end
