//
//  WCEditBuildTargetWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCBuildTarget;

@interface WCEditBuildTargetWindowController : NSWindowController {
	WCBuildTarget *_buildTarget;
}

@property (readwrite,retain,nonatomic) WCBuildTarget *buildTarget;

+ (id)editBuildTargetWindowControllerWithBuildTarget:(WCBuildTarget *)buildTarget;
- (id)initWithBuildTarget:(WCBuildTarget *)buildTarget;

- (void)showEditBuildTargetWindow;

- (IBAction)ok:(id)sender;
- (IBAction)manageBuildTargets:(id)sender;
- (IBAction)duplicateBuildTarget:(id)sender;

- (IBAction)newBuildDefine:(id)sender;
- (IBAction)deleteBuildDefine:(id)sender;

@end
