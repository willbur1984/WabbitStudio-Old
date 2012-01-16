//
//  WCSourceHighlighter.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

extern NSString *const WCSourceHighlighterCommentColorAttributeName;
extern NSString *const WCSourceHighlighterCommentFontAttributeName;

@class WCSourceScanner;

@interface WCSourceHighlighter : NSObject {
	__weak WCSourceScanner *_sourceScanner;
	BOOL _needsToPerformFullHighlight;
}
- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner;

- (void)performHighlightingInVisibleRange;
- (void)performHighlightingInRange:(NSRange)range;
- (void)performHighlightingInRange:(NSRange)range attributeName:(NSString *)attributeName;
@end
