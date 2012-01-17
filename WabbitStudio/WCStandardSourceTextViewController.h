//
//  WCStandardSourceTextViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/10/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceTextViewController.h"

@interface WCStandardSourceTextViewController : WCSourceTextViewController <NSSplitViewDelegate> {
	NSMutableArray *_assistantSplitViews;
	NSMutableArray *_assistantSourceTextViewControllers;
}
- (void)addAssistantEditorForSourceTextViewController:(WCSourceTextViewController *)firstSourceTextViewController;
- (void)removeAssistantEditorForSourceTextViewController:(WCSourceTextViewController *)sourceTextViewController;

- (void)breakUndoCoalescingForAllTextViews;
@end
