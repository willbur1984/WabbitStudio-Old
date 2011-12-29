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

- (NSString *)camelCaseString;
@end
