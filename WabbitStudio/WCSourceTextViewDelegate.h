//
//  WCSourceTextViewDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextView.h>

@class WCSourceTextView,WCSourceScanner,WCSourceHighlighter,WCSourceSymbol;

@protocol WCSourceTextViewDelegate <NSTextViewDelegate>
@required
- (NSArray *)sourceTokensForSourceTextView:(WCSourceTextView *)textView;
- (NSArray *)sourceSymbolsForSourceTextView:(WCSourceTextView *)textView;
- (NSArray *)macrosForSourceTextView:(WCSourceTextView *)textView;

- (NSArray *)sourceTextView:(WCSourceTextView *)textView sourceSymbolsForSymbolName:(NSString *)name;

- (WCSourceScanner *)sourceScannerForSourceTextView:(WCSourceTextView *)textView;

- (WCSourceHighlighter *)sourceHighlighterForSourceTextView:(WCSourceTextView *)textView;

- (void)handleJumpToDefinitionForSourceTextView:(WCSourceTextView *)textView sourceSymbol:(WCSourceSymbol *)symbol;
@end
