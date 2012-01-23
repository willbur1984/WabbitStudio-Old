//
//  WCProjectWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSNavigatorControlDataSource.h"
#import "RSNavigatorControlDelegate.h"
#import "WCProjectDocumentSettingsProvider.h"
#import "WCTabViewControllerDelegate.h"

@class WCProjectNavigatorViewController,WCTabViewController;

@interface WCProjectWindowController : NSWindowController <WCTabViewControllerDelegate,WCProjectDocumentSettingsProvider,RSNavigatorControlDataSource,RSNavigatorControlDelegate,NSSplitViewDelegate> {
	NSArray *_navigatorItemDictionaries;
	WCProjectNavigatorViewController *_projectNavigatorViewController;
	WCTabViewController *_tabViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet RSNavigatorControl *navigatorControl;
@property (readwrite,assign,nonatomic) IBOutlet NSSplitView *splitView;

@property (readonly,nonatomic) WCProjectNavigatorViewController *projectNavigatorViewController;
@property (readonly,nonatomic) WCTabViewController *tabViewController;
@end
