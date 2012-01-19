//
//  WCSourceHighlighter.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCSourceHighlighterDelegate.h"

extern NSString *const WCSourceHighlighterPlainTextAttributeName;
extern NSString *const WCSourceHighlighterCommentAttributeName;
extern NSString *const WCSourceHighlighterBinaryAttributeName;
extern NSString *const WCSourceHighlighterNumberAttributeName;
extern NSString *const WCSourceHighlighterStringAttributeName;
extern NSString *const WCSourceHighlighterRegisterAttributeName;
extern NSString *const WCSourceHighlighterDirectiveAttributeName;
extern NSString *const WCSourceHighlighterMneumonicAttributeName;
extern NSString *const WCSourceHighlighterHexadecimalAttributeName;
extern NSString *const WCSourceHighlighterPreProcessorAttributeName;
extern NSString *const WCSourceHighlighterConditionalAttributeName;
extern NSString *const WCSourceHighlighterLabelAttributeName;
extern NSString *const WCSourceHighlighterEquateAttributeName;
extern NSString *const WCSourceHighlighterDefineAttributeName;
extern NSString *const WCSourceHighlighterMacroAttributeName;

@class WCSourceScanner;

@interface WCSourceHighlighter : NSObject {
	__weak WCSourceScanner *_sourceScanner;
	BOOL _needsToPerformFullHighlight;
	__weak id <WCSourceHighlighterDelegate> _delegate;
}
@property (readwrite,assign) id <WCSourceHighlighterDelegate> delegate;

- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner;

- (void)performHighlightingInVisibleRange;
- (void)performHighlightingInRange:(NSRange)range;
- (void)performHighlightingForColorWithAttributeName:(NSString *)attributeName;
- (void)performHighlightingForFontWithAttributeName:(NSString *)attributeName;
- (void)performHighlightingForAllAttributes;
@end
