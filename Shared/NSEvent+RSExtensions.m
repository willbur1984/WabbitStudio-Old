//
//  NSEvent+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 7/12/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "NSEvent+RSExtensions.h"

@implementation NSEvent (NSEvent_RSExtensions)
- (BOOL)isCommandKeyPressed; {
	return (([self modifierFlags] & NSCommandKeyMask) != 0);
} 
- (BOOL)isOptionKeyPressed; {
	return (([self modifierFlags] & NSAlternateKeyMask) != 0);
}
- (BOOL)isControlKeyPressed; {
	return (([self modifierFlags] & NSControlKeyMask) != 0);
}
- (BOOL)isShiftKeyPressed; {
	return (([self modifierFlags] & NSShiftKeyMask) != 0);
}

- (BOOL)isOnlyCommandKeyPressed; {
	return (([self modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask);
}
- (BOOL)isOnlyOptionKeyPressed; {
	return (([self modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSAlternateKeyMask);
}
- (BOOL)isOnlyControlKeyPressed; {
	return (([self modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSControlKeyMask);
}
- (BOOL)isOnlyShiftKeyPressed; {
	return (([self modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSShiftKeyMask);
}

+ (BOOL)isCommandKeyPressed; {
	return [[NSApp currentEvent] isCommandKeyPressed];
}
+ (BOOL)isOptionKeyPressed; {
	return [[NSApp currentEvent] isOptionKeyPressed];
}
+ (BOOL)isControlKeyPressed; {
	return [[NSApp currentEvent] isControlKeyPressed];
}
+ (BOOL)isShiftKeyPressed; {
	return [[NSApp currentEvent] isShiftKeyPressed];
}

+ (BOOL)isOnlyCommandKeyPressed; {
	return [[NSApp currentEvent] isOnlyCommandKeyPressed];
}
+ (BOOL)isOnlyOptionKeyPressed; {
	return [[NSApp currentEvent] isOnlyOptionKeyPressed];
}
+ (BOOL)isOnlyControlKeyPressed; {
	return [[NSApp currentEvent] isOnlyControlKeyPressed];
}
+ (BOOL)isOnlyShiftKeyPressed; {
	return [[NSApp currentEvent] isOnlyShiftKeyPressed];
}
@end
