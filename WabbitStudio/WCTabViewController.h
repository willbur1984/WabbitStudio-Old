//
//  RSTabViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"

extern NSString *const WCTabViewControllerDidSelectTabNotification;
extern NSString *const WCTabViewControllerDidCloseTabNotification;

@class PSMTabBarControl,WCSourceFileDocument,WCSourceTextViewController;

@interface WCTabViewController : JAViewController <NSTabViewDelegate> {
	NSMapTable *_sourceFileDocumentsToSourceTextViewControllers;
	NSTabViewItem *_clickedTabViewItem;
}
@property (readwrite,assign,nonatomic) IBOutlet PSMTabBarControl *tabBarControl;

- (WCSourceTextViewController *)addTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (void)removeTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

@end
