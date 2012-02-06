//
//  WCSourceHighlighter.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCSourceHighlighterDelegate.h"

@class WCSourceScanner;

@interface WCSourceHighlighter : NSObject {
	__weak WCSourceScanner *_sourceScanner;
	BOOL _needsToPerformFullHighlight;
	__weak id <WCSourceHighlighterDelegate> _delegate;
}
@property (readwrite,assign) id <WCSourceHighlighterDelegate> delegate;

- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner;

- (void)performFullHighlightIfNeeded;
- (void)highlightSymbolsInVisibleRange;
- (void)highlightSymbolsInRange:(NSRange)range;

- (void)highlightAttributeString:(NSMutableAttributedString *)attributedString;
- (void)highlightAttributeString:(NSMutableAttributedString *)attributedString withArgumentNames:(NSSet *)argumentNames;

+ (void)highlightTextStorageAttributedString:(NSMutableAttributedString *)attributedString;
@end
