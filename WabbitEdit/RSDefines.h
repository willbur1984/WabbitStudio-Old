//
//  RSDefines.h
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#ifdef __OBJC__
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>

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

static const NSRange NSNotFoundRange = {.location = NSNotFound};
static const NSRange NSEmptyRange = {.location = 0, .length = 0};

static const NSSize NSSmallSize = {.width = 16.0, .height = 16.0};
static const NSSize NSMiniSize = {.width = 14.0, .height = 14.0};

static inline NSRect NSCenteredRect(NSRect rect1, NSRect rect2) {
	return NSMakeRect((NSMinX(rect2)+floor(NSWidth(rect2)/2.0))-floor(NSWidth(rect1)/2.0), (NSMinY(rect2)+floor(NSHeight(rect2)/2.0))-floor(NSHeight(rect1)/2.0), NSWidth(rect1), NSHeight(rect1));
}

static inline NSRect NSCenteredRectWithSize(NSSize size, NSRect rect) {
	return NSCenteredRect(NSMakeRect(NSMinX(rect), NSMinY(rect), size.width, size.height), rect);
}

static inline BOOL NSLocationInOrEqualToRange(NSUInteger loc, NSRange range) {
	return (loc - range.location <= range.length);
}

static inline uint8_t HexValueForCharacter(unichar character) {
	switch (character) {
		case '0':
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		case 'a':
		case 'A':
			return 10;
		case 'b':
		case 'B':
			return 11;
		case 'c':
		case 'C':
			return 12;
		case 'd':
		case 'D':
			return 13;
		case 'e':
		case 'E':
			return 14;
		case 'f':
		case 'F':
			return 15;
		default:
			return 0;
	}
}

static inline uint8_t ValueForCharacter(unichar character) {
	switch (character) {
		case '0':
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		default:
			return 0;
	}
}

static inline uint8_t BinaryValueForCharacter(unichar character) {
	switch (character) {
		case '0':
			return 0;
		case '1':
			return 1;
		default:
			return 0;
	}
}
#endif