//
//  WCSourceTextViewDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextView.h>

@class WCSourceTextView,WCSourceScanner;

@protocol WCSourceTextViewDelegate <NSTextViewDelegate>
@required
- (NSArray *)sourceTokensForSourceTextView:(WCSourceTextView *)textView;
- (NSArray *)sourceSymbolsForSourceTextView:(WCSourceTextView *)textView;

- (NSArray *)sourceTextView:(WCSourceTextView *)textView sourceSymbolsForSymbolName:(NSString *)name;

- (WCSourceScanner *)sourceScannerForSourceTextView:(WCSourceTextView *)textView;
@end
