//
//  RSToolTipManager.h
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSToolTipView.h"

@interface RSToolTipManager : NSWindowController {
@private	
    NSMapTable *_viewsToTrackingAreas;
	NSMapTable *_trackingAreasToViews;
	NSView <RSToolTipView> *_currentView;
	id _eventMonitor;
	NSTimer *_showTimer;
	NSTimer *_closeTimer;
	id _applicationDidResignActiveObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTextField *textField;

+ (RSToolTipManager *)sharedManager;

- (void)addView:(NSView <RSToolTipView> *)toolTipView;
- (void)removeView:(NSView <RSToolTipView> *)toolTipView;
@end
