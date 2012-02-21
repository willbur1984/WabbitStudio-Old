//
//  WCEditBuildTargetIncludesArrayController.h
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSRTVArrayController.h"

@class WCEditBuildTargetWindowController;

@interface WCEditBuildTargetIncludesArrayController : RSRTVArrayController <NSTableViewDataSource>
@property (readwrite,assign,nonatomic) IBOutlet WCEditBuildTargetWindowController *editBuildTargetWindowController;
@end
