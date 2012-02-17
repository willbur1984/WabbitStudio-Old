//
//  RSTabViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "WCProjectDocumentSettingsProvider.h"
#import "WCTabViewControllerDelegate.h"

extern NSString *const WCTabViewControllerDidSelectTabNotification;
extern NSString *const WCTabViewControllerDidCloseTabNotification;

@class PSMTabBarControl,WCSourceFileDocument,WCSourceTextViewController;

@interface WCTabViewController : NSViewController <WCProjectDocumentSettingsProvider,NSTabViewDelegate> {
	__weak id <WCTabViewControllerDelegate> _delegate;
	NSMapTable *_sourceFileDocumentsToSourceTextViewControllers;
	NSTabViewItem *_clickedTabViewItem;
	struct {
		unsigned int ignoreChangesToProjectDocumentSettings:1;
		unsigned int RESERVED:31;
	} _tabViewControllerFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet PSMTabBarControl *tabBarControl;
@property (readwrite,assign,nonatomic) IBOutlet NSTabView *tabView;

@property (readwrite,assign,nonatomic) id <WCTabViewControllerDelegate> delegate;

@property (readonly,nonatomic) NSMapTable *sourceFileDocumentsToSourceTextViewControllers;

- (WCSourceTextViewController *)addTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (void)removeTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

@end
