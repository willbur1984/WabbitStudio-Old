//
//  RSLCDViewManager.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSLCDViewManager.h"
#import "RSCalculator.h"
#import "RSLCDView.h"

@interface RSLCDViewManager ()
@property (readonly,nonatomic) NSHashTable *LCDViews;
@end

@implementation RSLCDViewManager
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_LCDViews = [[NSHashTable hashTableWithWeakObjects] retain];
	
	return self;
}

+ (RSLCDViewManager *)sharedManager; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (void)addLCDView:(RSLCDView *)lcdView; {
	if ([[self LCDViews] containsObject:lcdView])
		return;
	
	if (![[self LCDViews] count]) {
		_drawTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/FPS target:self selector:@selector(_drawTimerCallback:) userInfo:nil repeats:YES];
	}
	
	[[self LCDViews] addObject:lcdView];
}
- (void)removeLCDView:(RSLCDView *)lcdView; {
	[[self LCDViews] removeObject:lcdView];
	
	if (![[self LCDViews] count]) {
		[_drawTimer invalidate];
		_drawTimer = nil;
	}
}

@synthesize LCDViews=_LCDViews;

- (void)_drawTimerCallback:(NSTimer *)timer {
	calc_run_all();
	
	for (RSLCDView *lcdView in [self LCDViews]) {
		if ([[lcdView calculator] isRunning])
			[lcdView setNeedsDisplay:YES];
	}
	
	[timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0/FPS]];
}

@end
