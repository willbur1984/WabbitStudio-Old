//
//  NSArray+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSArray.h>

@class WCSourceToken,WCSourceSymbol;

@interface NSArray (WCExtensions)
- (NSUInteger)sourceTokenIndexForRange:(NSRange)range;
- (WCSourceToken *)sourceTokenForRange:(NSRange)range;
- (NSArray *)sourceTokensForRange:(NSRange)range;

- (NSUInteger)sourceSymbolIndexForRange:(NSRange)range;
- (WCSourceSymbol *)sourceSymbolForRange:(NSRange)range;
- (NSArray *)sourceSymbolsForRange:(NSRange)range;

- (NSUInteger)lineNumberForRange:(NSRange)range;
@end
