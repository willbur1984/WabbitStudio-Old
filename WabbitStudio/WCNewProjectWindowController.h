//
//  WCNewProjectWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@interface WCNewProjectWindowController : NSWindowController
+ (WCNewProjectWindowController *)sharedWindowController;

- (IBAction)cancel:(id)sender;
- (IBAction)createFromFolder:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;

- (id)createProjectWithContentsOfDirectory:(NSURL *)directoryURL error:(NSError **)outError;
@end
