//
//  WCSourceTextView.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextView.h>
#import "WCSourceTextViewDelegate.h"
#import "RSToolTipView.h"

@interface WCSourceTextView : NSTextView <RSToolTipView> {
	__weak id <WCSourceTextViewDelegate> _delegate;
}
@property (readwrite,assign,nonatomic) IBOutlet id <WCSourceTextViewDelegate> delegate;

- (IBAction)jumpToNextPlaceholder:(id)sender;
- (IBAction)jumpToPreviousPlaceholder:(id)sender;

- (IBAction)shiftLeft:(id)sender;
- (IBAction)shiftRight:(id)sender;

- (IBAction)commentUncommentSelection:(id)sender;
- (IBAction)commentSelection:(id)sender;
- (IBAction)uncommentSelection:(id)sender;
@end
