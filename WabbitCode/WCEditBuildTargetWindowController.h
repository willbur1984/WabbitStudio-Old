//
//  WCEditBuildTargetWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSWindowController.h>
#import "RSTableViewDelegate.h"

@class WCBuildTarget,WCProjectDocument,WCEditBuildTargetChooseInputFileAccessoryViewController;

@interface WCEditBuildTargetWindowController : NSWindowController <RSTableViewDelegate,NSControlTextEditingDelegate> {
	WCBuildTarget *_buildTarget;
	WCEditBuildTargetChooseInputFileAccessoryViewController *_chooseInputFileAccessoryViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTextField *nameTextField;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *definesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *definesTableView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *definesSearchField;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *includesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *includesTableView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *includesSearchField;

@property (readwrite,retain,nonatomic) WCBuildTarget *buildTarget;

+ (id)editBuildTargetWindowControllerWithBuildTarget:(WCBuildTarget *)buildTarget;
- (id)initWithBuildTarget:(WCBuildTarget *)buildTarget;

- (void)showEditBuildTargetWindow;

- (IBAction)ok:(id)sender;
- (IBAction)manageBuildTargets:(id)sender;

- (IBAction)newBuildDefine:(id)sender;
- (IBAction)deleteBuildDefine:(id)sender;
- (IBAction)newBuildInclude:(id)sender;
- (IBAction)deleteBuildInclude:(id)sender;

- (IBAction)chooseInputFile:(id)sender;

- (void)performCleanup;

@end
