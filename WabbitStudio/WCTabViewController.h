//
//  RSTabViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCProjectDocumentSettingsProvider.h"
#import "WCTabViewControllerDelegate.h"

extern NSString *const WCTabViewControllerDidSelectTabNotification;
extern NSString *const WCTabViewControllerDidCloseTabNotification;

@class PSMTabBarControl,WCSourceFileDocument,WCSourceTextViewController;

@interface WCTabViewController : JAViewController <WCProjectDocumentSettingsProvider,NSTabViewDelegate> {
	__weak id <WCTabViewControllerDelegate> _delegate;
	NSMapTable *_sourceFileDocumentsToSourceTextViewControllers;
	NSTabViewItem *_clickedTabViewItem;
	struct {
		unsigned int ignoreChangesToProjectDocumentSettings:1;
		unsigned int RESERVED:31;
	} _tabViewControllerFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet PSMTabBarControl *tabBarControl;

@property (readwrite,assign,nonatomic) id <WCTabViewControllerDelegate> delegate;

- (WCSourceTextViewController *)addTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (void)removeTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

@end
