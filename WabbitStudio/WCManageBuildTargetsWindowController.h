//
//  WCManageBuildTargetsWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCProjectDocument;

@interface WCManageBuildTargetsWindowController : NSWindowController {
	WCProjectDocument *_projectDocument;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;

+ (id)manageBuildTargetsWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)showManageBuildTargetsWindow;

- (IBAction)ok:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)newBuildTarget:(id)sender;
- (IBAction)newBuildTargetFromTemplate:(id)sender;
@end
