//
//  NSString+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WCExtensions)
- (NSUInteger)lineNumberForRange:(NSRange)range;
- (NSRange)rangeForLineNumber:(NSUInteger)lineNumber;
- (NSRange)lineNumberRangeForRange:(NSRange)range;
- (NSUInteger)numberOfLines;

- (NSString *)camelCaseString;

- (NSUInteger)valueFromHexadecimalString;
- (NSUInteger)valueFromBinaryString;
- (NSUInteger)valueFromString;

- (NSString *)stringByRemovingInvalidHexadecimalDigits;
- (NSString *)stringByRemovingInvalidBinaryDigits;
- (NSString *)stringByRemovingInvalidDigits;

+ (NSString *)UUIDString;
@end
