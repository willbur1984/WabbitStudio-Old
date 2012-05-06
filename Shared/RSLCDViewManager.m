//
//  RSLCDViewManager.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
		[[NSRunLoop mainRunLoop] addTimer:_drawTimer forMode:NSEventTrackingRunLoopMode];
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
	
	[timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0/FPS]];
	
	for (RSLCDView *lcdView in [self LCDViews])
		[lcdView setNeedsDisplay:YES];
}

@end
