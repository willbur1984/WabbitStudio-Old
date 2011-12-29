//
//  WCSourceHighlighter.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceScanner;

@interface WCSourceHighlighter : NSObject {
	__weak WCSourceScanner *_sourceScanner;
}
- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner;

- (void)performHighlightingInVisibleRange;
- (void)performHighlightingInRange:(NSRange)range;
@end
