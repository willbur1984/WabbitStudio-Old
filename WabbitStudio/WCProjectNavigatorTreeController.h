//
//  WCProjectNavigatorTreeController.h
//  WabbitStudio
//
//  Created by William Towe on 1/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTreeController.h>

@class WCProjectNavigatorViewController,WCAddToProjectAccessoryViewController;

@interface WCProjectNavigatorTreeController : NSTreeController <NSOutlineViewDataSource> {
	WCAddToProjectAccessoryViewController *_addToProjectAccessoryViewController;
	NSSet *_projectFilePaths;
}
@property (readwrite,assign,nonatomic) IBOutlet WCProjectNavigatorViewController *projectNavigatorViewController;
@end
