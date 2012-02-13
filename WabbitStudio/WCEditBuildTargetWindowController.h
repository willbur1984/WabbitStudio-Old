//
//  WCEditBuildTargetWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
@property (readwrite,assign,nonatomic) IBOutlet NSButton *chooseInputFileButton;

@property (readwrite,retain,nonatomic) WCBuildTarget *buildTarget;

+ (id)editBuildTargetWindowControllerWithBuildTarget:(WCBuildTarget *)buildTarget;
- (id)initWithBuildTarget:(WCBuildTarget *)buildTarget;

- (void)showEditBuildTargetWindow;

- (IBAction)ok:(id)sender;
- (IBAction)manageBuildTargets:(id)sender;

- (IBAction)newBuildDefine:(id)sender;
- (IBAction)deleteBuildDefine:(id)sender;

- (IBAction)chooseInputFile:(id)sender;

@end
