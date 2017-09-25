//
//  WCSourceTextView.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCFindableTextView.h"
#import "WCSourceTextViewDelegate.h"
#import "RSToolTipView.h"
#import "WCJumpInDataSource.h"

@class WCSourceTextStorage;

@interface WCSourceTextView : WCFindableTextView <RSToolTipView,WCJumpInDataSource> {
	__unsafe_unretained id <WCSourceTextViewDelegate> _delegate;
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
- (IBAction)jumpToCaller:(id)sender;

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

- (IBAction)jumpToNextIssue:(id)sender;
- (IBAction)jumpToPreviousIssue:(id)sender;

- (IBAction)fold:(id)sender;
- (IBAction)foldAll:(id)sender;
- (IBAction)unfold:(id)sender;
- (IBAction)unfoldAll:(id)sender;
- (IBAction)foldCommentBlocks:(id)sender;
- (IBAction)unfoldCommentBlocks:(id)sender;

- (IBAction)editAllMacroArgumentsInScope:(id)sender;

- (IBAction)openInSeparateEditor:(id)sender;
@end
