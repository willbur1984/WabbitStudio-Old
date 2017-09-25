//
//  WCJumpBarViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <AppKit/NSViewController.h>
#import "WCJumpBarDataSource.h"

@class WCJumpBar,WCJumpBarView;

@interface WCJumpBarViewController : NSViewController <NSMenuDelegate> {
	__unsafe_unretained NSTextView *_textView;
	__unsafe_unretained id <WCJumpBarDataSource> _jumpBarDataSource;
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
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *rightVerticalSeparator;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *addAssistantEditorButton;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *removeAssistantEditorButton;

@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,copy,nonatomic) NSString *textViewSelectedLineAndColumn;
@property (readonly,nonatomic) NSRect additionalEffectiveSplitViewRect;

- (id)initWithTextView:(NSTextView *)textView jumpBarDataSource:(id <WCJumpBarDataSource>)jumpBarDataSource;

- (IBAction)showTopLevelItems:(id)sender;
- (IBAction)showGroupItems:(id)sender;
- (IBAction)showDocumentItems:(id)sender;

- (void)performCleanup;
@end
