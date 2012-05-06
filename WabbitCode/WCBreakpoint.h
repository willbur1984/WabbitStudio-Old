//
//  WCBreakpoint.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSObject.h"

typedef enum _WCBreakpointType {
	WCBreakpointTypeAddress = 0,
	WCBreakpointTypeRead,
	WCBreakpointTypeWrite,
	WCBreakpointTypeFile
	
} WCBreakpointType;

@interface WCBreakpoint : RSObject <RSPlistArchiving,NSCopying,NSMutableCopying> {
	WCBreakpointType _type;
	uint16_t _address;
	uint8_t _page;
	NSString *_name;
	struct {
		unsigned int active:1;
		unsigned int RESERVED:31;
	} _breakpointFlags;
}
@property (readonly,nonatomic) WCBreakpointType type;
@property (readwrite,assign,nonatomic) uint16_t address;
@property (readwrite,assign,nonatomic) uint8_t page;
@property (readwrite,assign,nonatomic,getter = isActive) BOOL active;
@property (readonly,nonatomic) NSImage *icon;
@property (readwrite,copy,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *fileNameAndLineNumber;

+ (id)breakpointOfType:(WCBreakpointType)type address:(uint16_t)address page:(uint8_t)page;
- (id)initWithType:(WCBreakpointType)type address:(uint16_t)address page:(uint8_t)page;

+ (NSGradient *)disabledActiveBreakpointFillGradient;
+ (NSGradient *)disabledInactiveBreakpointFillGradient;
+ (NSColor *)disabledActiveBreakpointFillColor;
+ (NSColor *)disabledInactiveBreakpointFillColor;

+ (NSGradient *)enabledActiveBreakpointFillGradient;
+ (NSGradient *)enabledInactiveBreakpointFillGradient;
+ (NSColor *)enabledActiveBreakpointFillColor;
+ (NSColor *)enabledInactiveBreakpointFillColor;

+ (NSImage *)breakpointIconWithSize:(NSSize)size type:(WCBreakpointType)type active:(BOOL)active enabled:(BOOL)enabled;
@end
