//
//  WCSourceTextView.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCFindableTextView.h"
#import "WCSourceTextViewDelegate.h"
#import "RSToolTipView.h"
#import "WCJumpInDataSource.h"

@class WCSourceTextStorage;

@interface WCSourceTextView : WCFindableTextView <RSToolTipView,WCJumpInDataSource> {
	__weak id <WCSourceTextViewDelegate> _delegate;
	id _windowDidResignKeyObservingToken;
	id _windowDidBecomeKeyObservingToken;
	NSTimer *_completionTimer;
	NSTimer *_autoHighlightArgumentsTimer;
	NSIndexSet *_autoHighlightArgumentsRanges;
	struct {
		unsigned int editingArgumentsRanges:1;
		unsigned int RESERVED:31;
	} _textViewFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet id <WCSourceTextViewDelegate> delegate;
@property (readwrite,assign,nonatomic) BOOL wrapLines;
@property (readonly,nonatomic) WCSourceTextStorage *sourceTextStorage;

- (IBAction)jumpToNextPlaceholder:(id)sender;
- (IBAction)jumpToPreviousPlaceholder:(id)sender;

- (IBAction)findSelectedTextInProject:(id)sender;

- (IBAction)jumpToSelection:(id)sender;
- (IBAction)jumpToDefinition:(id)sender;

- (IBAction)jumpToLine:(id)sender;
- (IBAction)jumpInFile:(id)sender;

- (IBAction)shiftLeft:(id)sender;
- (IBAction)shiftRight:(id)sender;

- (IBAction)commentUncommentSelection:(id)sender;
- (IBAction)commentSelection:(id)sender;
- (IBAction)uncommentSelection:(id)sender;

- (IBAction)toggleBookmarkAtCurrentLine:(id)sender;
- (IBAction)addBookmarkAtCurrentLine:(id)sender;
- (IBAction)removeBookmarkAtCurrentLine:(id)sender;
- (IBAction)removeAllBookmarks:(id)sender;

- (IBAction)toggleBreakpointAtCurrentLine:(id)sender;

- (IBAction)jumpToNextBookmark:(id)sender;
- (IBAction)jumpToPreviousBookmark:(id)sender;

- (IBAction)fold:(id)sender;
- (IBAction)foldAll:(id)sender;
- (IBAction)unfold:(id)sender;
- (IBAction)unfoldAll:(id)sender;
- (IBAction)foldCommentBlocks:(id)sender;
- (IBAction)unfoldCommentBlocks:(id)sender;

- (IBAction)editAllMacroArgumentsInScope:(id)sender;

- (IBAction)openInSeparateEditor:(id)sender;
@end
