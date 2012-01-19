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
	NSArray *_includesFiles;
	NSMenu *_filesMenu;
	NSMapTable *_fileSubmenusToFileContainers;
	NSArray *_unsavedFiles;
}
@property (readwrite,assign,nonatomic) IBOutlet WCJumpBar *jumpBar;
@property (readwrite,assign,nonatomic) IBOutlet NSMenu *recentFilesMenu;
@property (readwrite,assign,nonatomic) IBOutlet NSMenu *unsavedFilesMenu;
@property (readwrite,assign,nonatomic) IBOutlet NSMenu *includesMenu;

@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,copy,nonatomic) NSString *textViewSelectedLineAndColumn;
@property (readonly,nonatomic) NSRect additionalEffectiveSplitViewRect;

- (id)initWithTextView:(NSTextView *)textView jumpBarDataSource:(id <WCJumpBarDataSource>)jumpBarDataSource;

- (IBAction)showTopLevelItems:(id)sender;
- (IBAction)showGroupItems:(id)sender;
- (IBAction)showDocumentItems:(id)sender;
@end
