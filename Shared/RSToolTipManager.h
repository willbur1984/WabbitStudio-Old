//
//  RSToolTipManager.h
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSToolTipView.h"

@interface RSToolTipManager : NSWindowController <NSAnimationDelegate> {
@private	
    NSMapTable *_viewsToTrackingAreas;
	NSMapTable *_trackingAreasToViews;
	id _eventMonitor;
	NSTimer *_delayTimer;
	NSView <RSToolTipView> *_currentView;
	BOOL _isShowingToolTip;
	id _applicationDidResignActiveObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTextField *textField;

+ (RSToolTipManager *)sharedManager;

- (void)addView:(NSView <RSToolTipView> *)toolTipView;
- (void)removeView:(NSView <RSToolTipView> *)toolTipView;
@end
