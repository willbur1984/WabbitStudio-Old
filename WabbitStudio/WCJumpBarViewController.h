//
//  WCJumpBarViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "WCJumpBarDataSource.h"

@class WCJumpBar,WCJumpBarView;

@interface WCJumpBarViewController : NSViewController <NSMenuDelegate> {
	__weak NSTextView *_textView;
	__weak id <WCJumpBarDataSource> _jumpBarDataSource;
	NSString *_textViewSelectedLineAndColumn;
	NSMenu *_symbolsMenu;
}
@property (readwrite,assign,nonatomic) IBOutlet WCJumpBar *jumpBar;
@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,copy,nonatomic) NSString *textViewSelectedLineAndColumn;
@property (readonly,nonatomic) NSRect additionalEffectiveSplitViewRect;

- (id)initWithTextView:(NSTextView *)textView jumpBarDataSource:(id <WCJumpBarDataSource>)jumpBarDataSource;

- (IBAction)showDocumentItems:(id)sender;
@end
