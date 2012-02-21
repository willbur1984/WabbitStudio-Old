//
//  WCSourceHighlighterDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceHighlighter;

@protocol WCSourceHighlighterDelegate <NSObject>
@required
- (NSArray *)labelSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter;
- (NSArray *)equateSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter;
- (NSArray *)defineSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter;
- (NSArray *)macroSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter;
@end
