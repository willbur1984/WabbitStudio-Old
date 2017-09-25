//
//  WCSourceTextViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JAViewController.h"
#import "WCSourceTextViewDelegate.h"
#import "WCSourceRulerViewDelegate.h"
#import "WCSourceScrollView.h"

@class WCSourceTextView,WCSourceTextStorage,WCSourceHighlighter,WCJumpBarViewController,WCSourceFileDocument,WCStandardSourceTextViewController;

@interface WCSourceTextViewController : NSViewController <WCSourceTextViewDelegate,WCSourceRulerViewDelegate,WCSourceScrollViewDelegate,NSLayoutManagerDelegate> {
	__unsafe_unretained WCStandardSourceTextViewController *_standardSourceTextViewController;
	__unsafe_unretained WCSourceFileDocument *_sourceFileDocument;
	WCJumpBarViewController *_jumpBarViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet WCSourceTextView *textView;
@property (readwrite,assign,nonatomic) IBOutlet NSScrollView *scrollView;

@property (readonly,nonatomic) WCSourceHighlighter *sourceHighlighter;
@property (readonly,nonatomic) WCJumpBarViewController *jumpBarViewController;
@property (readonly,nonatomic) WCSourceFileDocument *sourceFileDocument;
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;

- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument standardSourceTextViewController:(WCStandardSourceTextViewController *)sourceTextViewController;

- (IBAction)showStandardEditor:(id)sender;
- (IBAction)showTopLevelItems:(id)sender;
- (IBAction)showGroupItems:(id)sender;
- (IBAction)showDocumentItems:(id)sender;

- (IBAction)showAssistantEditor:(id)sender;
- (IBAction)addAssistantEditor:(id)sender;
- (IBAction)removeAssistantEditor:(id)sender;

- (IBAction)revealInProjectNavigator:(id)sender;
- (IBAction)showInFinder:(id)sender;

- (IBAction)moveFocusToNextArea:(id)sender;
- (IBAction)moveFocusToPreviousArea:(id)sender;

- (void)performCleanup;
@end
