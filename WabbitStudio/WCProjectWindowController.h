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

@class WCProjectNavigatorViewController;

@interface WCProjectWindowController : NSWindowController <RSNavigatorControlDataSource,RSNavigatorControlDelegate,NSSplitViewDelegate> {
	NSArray *_navigatorItemDictionaries;
	WCProjectNavigatorViewController *_projectNavigatorViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet RSNavigatorControl *navigatorControl;

@property (readonly,nonatomic) WCProjectNavigatorViewController *projectNavigatorViewController;
@end
