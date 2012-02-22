//
//  RSLCDViewManager.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class RSLCDView;

@interface RSLCDViewManager : NSObject {
	NSHashTable *_LCDViews;
	NSTimer *_drawTimer;
}
+ (RSLCDViewManager *)sharedManager;

- (void)addLCDView:(RSLCDView *)lcdView;
- (void)removeLCDView:(RSLCDView *)lcdView;
@end
