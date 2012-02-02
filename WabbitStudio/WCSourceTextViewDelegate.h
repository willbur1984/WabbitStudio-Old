//
//  WCSourceTextViewDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextView.h>

@class WCSourceTextView,WCSourceScanner,WCSourceHighlighter,WCSourceSymbol,WCFile,WCProjectDocument,WCSourceFileDocument;

@protocol WCSourceTextViewDelegate <NSTextViewDelegate>
@required
- (NSArray *)sourceTokensForSourceTextView:(WCSourceTextView *)textView;
- (NSArray *)sourceSymbolsForSourceTextView:(WCSourceTextView *)textView;
- (NSArray *)macrosForSourceTextView:(WCSourceTextView *)textView;

- (NSArray *)sourceTextView:(WCSourceTextView *)textView sourceSymbolsForSymbolName:(NSString *)name;

- (WCSourceScanner *)sourceScannerForSourceTextView:(WCSourceTextView *)textView;

- (WCSourceHighlighter *)sourceHighlighterForSourceTextView:(WCSourceTextView *)textView;

- (WCProjectDocument *)projectDocumentForSourceTextView:(WCSourceTextView *)textView;
- (WCSourceFileDocument *)sourceFileDocumentForSourceTextView:(WCSourceTextView *)textView;

- (void)handleJumpToDefinitionForSourceTextView:(WCSourceTextView *)textView sourceSymbol:(WCSourceSymbol *)symbol;
- (void)handleJumpToDefinitionForSourceTextView:(WCSourceTextView *)textView file:(WCFile *)file;
@end
