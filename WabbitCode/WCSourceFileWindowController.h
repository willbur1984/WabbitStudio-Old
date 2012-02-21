//
//  WCSourceFileWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCStandardSourceTextViewController;

@interface WCSourceFileWindowController : NSWindowController <NSWindowDelegate> {
	WCStandardSourceTextViewController *_sourceTextViewController;
}
@property (readonly,nonatomic) WCStandardSourceTextViewController *sourceTextViewController;
@end
