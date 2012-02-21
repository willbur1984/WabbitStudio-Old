//
//  WCSourceTextStorageDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <AppKit/NSTextStorage.h>

@class WCSourceTextStorage,WCSourceHighlighter,WCSourceScanner;

@protocol WCSourceTextStorageDelegate <NSTextStorageDelegate>
@required
- (WCSourceHighlighter *)sourceHighlighterForSourceTextStorage:(WCSourceTextStorage *)textStorage;
- (WCSourceScanner *)sourceScannerForSourceTextStorage:(WCSourceTextStorage *)textStorage;
@end
