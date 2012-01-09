//
//  WCSourceFileWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCSourceTextViewController,WCSplitView;

@interface WCSourceFileWindowController : NSWindowController <NSSplitViewDelegate> {
	WCSourceTextViewController *_sourceTextViewController;
	WCSplitView *_splitView;
	WCSourceTextViewController *_bottomSourceTextViewController;
}
- (IBAction)toggleEditorSplitView:(id)sender;
@end
