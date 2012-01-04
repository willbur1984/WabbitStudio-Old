//
//  RSBezelWindowController.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSBezelWindowController.h"
#import "RSDefines.h"
#import "RSBezelView.h"
#import <QuartzCore/QuartzCore.h>

@interface RSBezelWindowController ()

@end

@implementation RSBezelWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
	return [self initWithWindowNibName:[self windowNibName]];
}

- (NSString *)windowNibName {
	return @"RSBezelWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CAAnimation *animation = [CABasicAnimation animation];
		[animation setDuration:0.25];
		[animation setDelegate:self];
		[[self window] setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:animation,@"alphaValue", nil]];
	});
}
#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
	if (flag)
		[[self window] orderOut:nil];
}
#pragma mark *** Public Methods ***
+ (RSBezelWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

static const NSTimeInterval kFadeDelay = 0.5;
- (void)showImage:(NSImage *)image atPoint:(NSPoint)point; {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self window] setAlphaValue:1.0];
	
	[[self bezelView] setImage:image];
	
	[[self window] setFrame:[[self window] frameRectForContentRect:[[self bezelView] frame]] display:YES];
	[[self window] setFrameTopLeftPoint:NSMakePoint(point.x-floor(NSWidth([[self window] frame])/2.0), point.y-floor(NSHeight([[self window] frame])/2.0))];
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:kFadeDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}
- (void)showImage:(NSImage *)image centeredInView:(NSView *)view; {
	NSPoint centerPoint = NSCenteredPointInRect([view bounds]);
	
	[self showImage:image atPoint:[[view window] convertBaseToScreen:[view convertPointToBase:centerPoint]]];
}

- (void)showString:(NSString *)string atPoint:(NSPoint)point; {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self window] setAlphaValue:1.0];
	
	[[self bezelView] setString:string];
	
	[[self window] setFrame:[[self window] frameRectForContentRect:[[self bezelView] frame]] display:YES];
	[[self window] setFrameTopLeftPoint:NSMakePoint(point.x-floor(NSWidth([[self window] frame])/2.0), point.y-floor(NSHeight([[self window] frame])/2.0))];
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:kFadeDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}
- (void)showString:(NSString *)string centeredInView:(NSView *)view; {
	NSPoint centerPoint = NSCenteredPointInRect([view bounds]);
	
	[self showString:string atPoint:[[view window] convertBaseToScreen:[view convertPointToBase:centerPoint]]];
}
#pragma mark Properties
@synthesize bezelView=_bezelView;
#pragma mark *** Private Methods ***
#pragma mark Callbacks
- (void)_closeTimerCallback:(NSTimer *)timer {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[[self window] animator] setAlphaValue:0.0];
}

@end
