//
//  WCEditBuildTargetChooseInputFileViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>

@class WCEditBuildTargetWindowController;

@interface WCEditBuildTargetChooseInputFileViewController : NSViewController <NSPopoverDelegate> {
	__weak WCEditBuildTargetWindowController *_editBuildTargetWindowController;
	NSPopover *_popover;
}
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;

@property (readonly,nonatomic) WCEditBuildTargetWindowController *editBuildTargetWindowController;

+ (id)editBuildTargetChooseInputFileViewControllerWithEditBuildTargetWindowController:(WCEditBuildTargetWindowController *)editBuildTargetWindowController;
- (id)initWithEditBuildTargetWindowController:(WCEditBuildTargetWindowController *)editBuildTargetWindowController;

- (void)showChooseInputFileViewRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;
- (void)hideChooseInputFileView;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
@end
