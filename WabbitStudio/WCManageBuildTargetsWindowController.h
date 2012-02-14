//
//  WCManageBuildTargetsWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSTableViewDelegate.h"

@class WCProjectDocument;

@interface WCManageBuildTargetsWindowController : NSWindowController <RSTableViewDelegate> {
	__weak WCProjectDocument *_projectDocument;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readwrite,copy,nonatomic) NSArray *selectedBuildTargets;

+ (id)manageBuildTargetsWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)showManageBuildTargetsWindow;

- (IBAction)ok:(id)sender;
- (IBAction)editBuildTarget:(id)sender;
- (IBAction)newBuildTarget:(id)sender;
- (IBAction)newBuildTargetFromTemplate:(id)sender;
- (IBAction)deleteBuildTarget:(id)sender;
- (IBAction)duplicateBuildTarget:(id)sender;
- (IBAction)renameBuildTarget:(id)sender;
@end
