//
//  NSAttributedString+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSAttributedString.h>

@interface NSAttributedString (WCExtensions)
- (NSRange)nextArgumentPlaceholderRangeForRange:(NSRange)compareRange inRange:(NSRange)range wrapAround:(BOOL)wrapAround;
- (NSRange)previousArgumentPlaceholderRangeForRange:(NSRange)compareRange inRange:(NSRange)range wrapAround:(BOOL)wrapAround;
@end
