//
//  WCSourceTextViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCSourceTextViewDelegate.h"

@class WCSourceTextView,WCSourceTextStorage,WCSourceHighlighter,WCJumpBarViewController,WCSourceFileDocument,WCStandardSourceTextViewController;

@interface WCSourceTextViewController : JAViewController <WCSourceTextViewDelegate> {
	__weak WCStandardSourceTextViewController *_standardSourceTextViewController;
	__weak WCSourceFileDocument *_sourceFileDocument;
	NSTimer *_scrollingHighlightTimer;
	WCJumpBarViewController *_jumpBarViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet WCSourceTextView *textView;

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

- (void)performCleanup;
@end
