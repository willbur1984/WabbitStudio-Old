//
//  WCOpenQuicklySearchOperation.h
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSOperation.h>

@class WCOpenQuicklyWindowController;

@interface WCOpenQuicklySearchOperation : NSOperation {
	__weak WCOpenQuicklyWindowController *_windowController;
	NSString *_searchString;
}
- (id)initWithOpenQuicklyWindowController:(WCOpenQuicklyWindowController *)windowController;
@end
