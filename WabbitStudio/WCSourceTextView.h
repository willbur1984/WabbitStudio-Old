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

@interface WCSourceTextView : WCFindableTextView <RSToolTipView> {
	__weak id <WCSourceTextViewDelegate> _delegate;
	id _windowDidResignKeyObservingToken;
	id _windowDidBecomeKeyObservingToken;
	id _windowDidResizeObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet id <WCSourceTextViewDelegate> delegate;

- (IBAction)jumpToNextPlaceholder:(id)sender;
- (IBAction)jumpToPreviousPlaceholder:(id)sender;

- (IBAction)jumpToSelection:(id)sender;
- (IBAction)jumpToDefinition:(id)sender;

- (IBAction)shiftLeft:(id)sender;
- (IBAction)shiftRight:(id)sender;

- (IBAction)commentUncommentSelection:(id)sender;
- (IBAction)commentSelection:(id)sender;
- (IBAction)uncommentSelection:(id)sender;
@end