//
//  NSEvent+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 7/12/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
