//
//  NSPointerArray+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (WCExtensions)
+ (id)pointerArrayForRanges;

- (NSRange)rangeForRange:(NSRange)range;
@end
