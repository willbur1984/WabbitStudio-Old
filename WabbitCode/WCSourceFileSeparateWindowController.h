//
//  WCSourceFileSeparateWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/29/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "WCTabViewContext.h"
#import "WCTabViewControllerDelegate.h"

@class WCTabViewController,WCSourceFileDocument;

@interface WCSourceFileSeparateWindowController : NSWindowController <WCTabViewContext,WCTabViewControllerDelegate,NSWindowDelegate> {
	__weak WCSourceFileDocument *_sourceFileDocument;
	WCTabViewController *_tabViewController;
	BOOL _windowShouldClose;
}
@property (readonly,nonatomic) WCTabViewController *tabViewController;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) WCSourceFileDocument *sourceFileDocument;

- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
@end
