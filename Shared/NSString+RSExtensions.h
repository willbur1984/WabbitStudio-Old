//
//  NSString+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (RSExtensions)
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
