//
//  WCBreakpoint.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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

+ (id)breakpointOfType:(WCBreakpointType)type address:(uint16_t)address page:(uint8_t)page;
- (id)initWithType:(WCBreakpointType)type address:(uint16_t)address page:(uint8_t)page;

+ (NSGradient *)activeBreakpointFillGradient;
+ (NSGradient *)inactiveBreakpointFillGradient;
+ (NSColor *)activeBreakpointFillColor;
+ (NSColor *)inactiveBreakpointFillColor;

+ (NSImage *)breakpointIconWithSize:(NSSize)size type:(WCBreakpointType)type active:(BOOL)active;
@end
