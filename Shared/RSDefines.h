//
//  RSDefines.h
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#ifndef RSDEFINES_H
#define RSDEFINES_H

#define KEY_CODE_RETURN 36
#define KEY_CODE_ENTER 76
#define KEY_CODE_FUNCTION6 97
#define KEY_CODE_ESCAPE 53
#define KEY_CODE_LEFT_ARROW 123
#define KEY_CODE_RIGHT_ARROW 124
#define KEY_CODE_UP_ARROW 126
#define KEY_CODE_DOWN_ARROW 125
#define KEY_CODE_TAB 48
#define KEY_CODE_SPACE 49
#define KEY_CODE_DELETE 51
#define KEY_CODE_DELETE_FORWARD 117

#define LOCALIZED_STRING_OK NSLocalizedString(@"Ok",@"Ok")
#define LOCALIZED_STRING_DELETE NSLocalizedString(@"Delete",@"Delete")
#define LOCALIZED_STRING_DELETE_WITH_ELLIPSIS NSLocalizedString(@"Delete\u2026",@"Delete with ellipsis")
#define LOCALIZED_STRING_CANCEL NSLocalizedString(@"Cancel",@"Cancel")
#define LOCALIZED_STRING_CHOOSE NSLocalizedString(@"Choose",@"Choose")
#define LOCALIZED_STRING_CHOOSE_WITH_ELLIPSIS NSLocalizedString(@"Choose\u2026",@"Choose with ellipsis")
#define LOCALIZED_STRING_CLOSE NSLocalizedString(@"Close",@"Close")
#define LOCALIZED_STRING_LOAD NSLocalizedString(@"Load",@"Load")

#define NSLogObject(objectToLog) NSLog(@"%@",(objectToLog))
#define NSLogRange(rangeToLog) NSLog(@"%@",NSStringFromRange(rangeToLog))
#define NSLogRect(rectToLog) NSLog(@"%@",NSStringFromRect(rectToLog))
#define NSLogInteger(intToLog) NSLog(@"%ld",(intToLog))
#define NSLogUnsignedInteger(uintToLog) NSLog(@"%lu",(uintToLog))
#define NSLogSize(sizeToLog) NSLog(@"%@",NSStringFromSize(sizeToLog))
#define NSLogFloat(floatToLog) NSLog(@"%f",(floatToLog))

#define RSLogObject(objectToLog) RSLog(@"%@",(objectToLog))
#define RSLogRange(rangeToLog) RSLog(@"%@",NSStringFromRange(rangeToLog))
#define RSLogRect(rectToLog) RSLog(@"%@",NSStringFromRect(rectToLog))
#define RSLogInteger(intToLog) RSLog(@"%ld",(intToLog))
#define RSLogUnsignedInteger(uintToLog) RSLog(@"%lu",(uintToLog))
#define RSLogSize(sizeToLog) RSLog(@"%@",NSStringFromSize(sizeToLog))
#define RSLogFloat(floatToLog) RSLog(@"%f",(floatToLog))

#ifdef __OBJC__
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>

static const NSRange NSNotFoundRange = {.location = NSNotFound};
static const NSRange NSEmptyRange = {.location = 0, .length = 0};

static const NSSize NSSmallSize = {.width = 16.0, .height = 16.0};
static const NSSize NSMiniSize = {.width = 14.0, .height = 14.0};

static inline void RSLog(NSString *format, ...) {
	va_list args;
	va_start(args, format);
	
	NSString *string = [[NSString alloc] initWithFormat:[format stringByAppendingString:@"\n"] arguments:args];
	
	va_end(args);
	
	[(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[string release];
}

static inline NSRect NSCenteredRect(NSRect rect1, NSRect rect2) {
	return NSMakeRect((NSMinX(rect2)+floor(NSWidth(rect2)/2.0))-floor(NSWidth(rect1)/2.0), (NSMinY(rect2)+floor(NSHeight(rect2)/2.0))-floor(NSHeight(rect1)/2.0), NSWidth(rect1), NSHeight(rect1));
}

static inline NSRect NSCenteredRectWithSize(NSSize size, NSRect rect) {
	return NSCenteredRect(NSMakeRect(NSMinX(rect), NSMinY(rect), size.width, size.height), rect);
}

static inline NSPoint NSCenteredPointInRect(NSRect rect) {
	return NSMakePoint(NSMinX(rect)+floor(NSWidth(rect)/2.0), NSMinY(rect)+floor(NSHeight(rect)/2.0));
}

static inline BOOL NSLocationInOrEqualToRange(NSUInteger loc, NSRange range) {
	return (loc - range.location <= range.length);
}

#endif
#endif