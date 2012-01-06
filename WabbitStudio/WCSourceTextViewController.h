//
//  WCSourceTextViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "WCSourceTextViewDelegate.h"

@class WCSourceScanner,WCSourceTextView,WCSourceTextStorage,WCSourceHighlighter;

@interface WCSourceTextViewController : NSViewController <WCSourceTextViewDelegate> {
	__weak WCSourceScanner *_sourceScanner;
	__weak WCSourceTextStorage *_textStorage;
	__weak WCSourceHighlighter *_sourceHighlighter;
	NSTimer *_scrollingHighlightTimer;
}
@property (readwrite,assign,nonatomic) IBOutlet WCSourceTextView *textView;

- (id)initWithTextStorage:(WCSourceTextStorage *)textStorage sourceScanner:(WCSourceScanner *)sourceScanner sourceHighlighter:(WCSourceHighlighter *)sourceHighlighter;
@end
