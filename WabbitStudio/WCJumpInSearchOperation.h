//
//  WCJumpInSearchOperation.h
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSOperation.h>

@class WCJumpInWindowController;

@interface WCJumpInSearchOperation : NSOperation {
	__weak WCJumpInWindowController *_windowController;
	NSString *_searchString;
}
- (id)initWithJumpInWindowController:(WCJumpInWindowController *)windowController;
@end
