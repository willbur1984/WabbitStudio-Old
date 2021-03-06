//
//  WCBreakpoint.m
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

#import "WCBreakpoint.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCEditorViewController.h"

static NSString *const WCBreakpointTypeKey = @"type";
static NSString *const WCBreakpointAddressKey = @"address";
static NSString *const WCBreakpointPageKey = @"page";
static NSString *const WCBreakpointActiveKey = @"active";

@implementation WCBreakpoint
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_name release];
	[super dealloc];
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCBreakpoint *copy = [[WCBreakpoint alloc] init];
	
	copy->_type = _type;
	copy->_address = _address;
	copy->_page = _page;
	copy->_breakpointFlags = _breakpointFlags;
	copy->_name = [_name copy];
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCBreakpoint *copy = [[WCBreakpoint alloc] init];
	
	copy->_type = _type;
	copy->_address = _address;
	copy->_page = _page;
	copy->_breakpointFlags = _breakpointFlags;
	copy->_name = [_name copy];
	
	return copy;
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:[NSNumber numberWithUnsignedInt:[self type]] forKey:WCBreakpointTypeKey];
	[retval setObject:[NSNumber numberWithUnsignedShort:[self address]] forKey:WCBreakpointAddressKey];
	[retval setObject:[NSNumber numberWithUnsignedChar:[self page]] forKey:WCBreakpointPageKey];
	[retval setObject:[NSNumber numberWithBool:[self isActive]] forKey:WCBreakpointActiveKey];
	
	return [[retval copy] autorelease];
}

- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_type = [[plistRepresentation objectForKey:WCBreakpointTypeKey] unsignedIntValue];
	_address = [[plistRepresentation objectForKey:WCBreakpointAddressKey] unsignedShortValue];
	_page = [[plistRepresentation objectForKey:WCBreakpointPageKey] unsignedCharValue];
	_breakpointFlags.active = [[plistRepresentation objectForKey:WCBreakpointActiveKey] boolValue];
	
	return self;
}
#pragma mark *** Public Methods ***
+ (id)breakpointOfType:(WCBreakpointType)type address:(uint16_t)address page:(uint8_t)page; {
	return [[[[self class] alloc] initWithType:type address:address page:page] autorelease];
}
- (id)initWithType:(WCBreakpointType)type address:(uint16_t)address page:(uint8_t)page; {
	if (!(self = [super init]))
		return nil;
	
	_type = type;
	_address = address;
	_page = page;
	_breakpointFlags.active = YES;
	
	return self;
}

+ (NSGradient *)enabledActiveBreakpointFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:84.0/255.0 green:138.0/255.0 blue:192.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:56.0/255.0 green:118.0/255.0 blue:179.0/255.0 alpha:1.0]];
	});
	return retval;
}
+ (NSGradient *)enabledInactiveBreakpointFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:84.0/255.0 green:138.0/255.0 blue:192.0/255.0 alpha:0.5] endingColor:[NSColor colorWithCalibratedRed:56.0/255.0 green:118.0/255.0 blue:179.0/255.0 alpha:0.5]];
	});
	return retval;
}
+ (NSColor *)enabledActiveBreakpointFillColor; {
	return [NSColor colorWithCalibratedRed:32.0/255.0 green:94.0/255.0 blue:160.0/255.0 alpha:1.0];
}
+ (NSColor *)enabledInactiveBreakpointFillColor; {
	return [NSColor colorWithCalibratedRed:32.0/255.0 green:94.0/255.0 blue:160.0/255.0 alpha:0.5];
}

+ (NSGradient *)disabledActiveBreakpointFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;		
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:166.0/255.0 green:168.0/255.0 blue:171.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:141.0/255.0 green:144.0/255.0 blue:147.0/255.0 alpha:1.0]];
	});
	return retval;
}
+ (NSGradient *)disabledInactiveBreakpointFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;		
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:166.0/255.0 green:168.0/255.0 blue:171.0/255.0 alpha:0.5] endingColor:[NSColor colorWithCalibratedRed:141.0/255.0 green:144.0/255.0 blue:147.0/255.0 alpha:0.5]];
	});
	return retval;
}
+ (NSColor *)disabledActiveBreakpointFillColor; {
	return [NSColor colorWithCalibratedRed:118.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0];
}
+ (NSColor *)disabledInactiveBreakpointFillColor; {
	return [NSColor colorWithCalibratedRed:118.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:0.5];
}

+ (NSImage *)breakpointIconWithSize:(NSSize)size type:(WCBreakpointType)type active:(BOOL)active enabled:(BOOL)enabled; {
	static const CGFloat kCornerRadius = 3.0;
	const CGFloat kTriangleInset = ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorShowCodeFoldingRibbonKey])?8.0:3.0;
	NSImage *retval = [[[NSImage alloc] initWithSize:size] autorelease];
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[path moveToPoint:NSMakePoint(size.width, floor(size.height/2.0))];
	[path lineToPoint:NSMakePoint(size.width-kTriangleInset, size.height)];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(kCornerRadius, size.height-kCornerRadius) radius:kCornerRadius startAngle:90.0 endAngle:180.0];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(kCornerRadius, kCornerRadius) radius:kCornerRadius startAngle:180.0 endAngle:270.0];
	[path lineToPoint:NSMakePoint(size.width-kTriangleInset, 0.0)];
	[path closePath];
		
	[retval lockFocus];
	
	static const CGFloat kGradientFillAngle = 270.0;
	
	if (enabled) {
		if (active) {
			[[self enabledActiveBreakpointFillGradient] drawInBezierPath:path angle:kGradientFillAngle];
			[[self enabledActiveBreakpointFillColor] setStroke];
		}
		else {
			[[self enabledInactiveBreakpointFillGradient] drawInBezierPath:path angle:kGradientFillAngle];
			[[self enabledInactiveBreakpointFillColor] setStroke];
		}
	}
	else {
		if (active) {
			[[self disabledActiveBreakpointFillGradient] drawInBezierPath:path angle:kGradientFillAngle];
			[[self disabledActiveBreakpointFillColor] setStroke];
		}
		else {
			[[self disabledInactiveBreakpointFillGradient] drawInBezierPath:path angle:kGradientFillAngle];
			[[self disabledInactiveBreakpointFillColor] setStroke];
		}
	}
	
	[path strokeInside];
	
	[retval unlockFocus];
	
	return retval;
}
#pragma mark Properties
@synthesize type=_type;
@synthesize address=_address;
@synthesize page=_page;
@dynamic active;
- (BOOL)isActive {
	return _breakpointFlags.active;
}
- (void)setActive:(BOOL)active {
	_breakpointFlags.active = active;
}
@dynamic icon;
- (NSImage *)icon {
	return [[self class] breakpointIconWithSize:NSMakeSize(24.0, 12.0) type:[self type] active:[self isActive] enabled:YES];
}
+ (NSSet *)keyPathsForValuesAffectingIcon {
	return [NSSet setWithObjects:@"active", nil];
}
@synthesize name=_name;
@dynamic fileNameAndLineNumber;

@end
