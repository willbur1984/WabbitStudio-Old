//
//  WCProjectNavigatorTreeController.h
//  WabbitStudio
//
//  Created by William Towe on 1/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTreeController.h>

@class WCProjectNavigatorViewController;

@interface WCProjectNavigatorTreeController : NSTreeController <NSOutlineViewDataSource>
@property (readwrite,assign,nonatomic) IBOutlet WCProjectNavigatorViewController *projectNavigatorViewController;
@end
