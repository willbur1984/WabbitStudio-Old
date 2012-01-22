//
//  RSBezelWindowController.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSBezelWidgetManager.h"
#import "RSDefines.h"
#import "RSBezelView.h"
#import <QuartzCore/QuartzCore.h>

@interface RSBezelWidgetManager ()

@end

@implementation RSBezelWidgetManager
#pragma mark *** Subclass Overrides ***
- (id)init {
	return [super initWithWindowNibName:[self windowNibName]];
}

- (NSString *)windowNibName {
	return @"RSBezelWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CAAnimation *animation = [CABasicAnimation animation];
		[animation setDuration:0.35];
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
+ (RSBezelWidgetManager *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

static const NSTimeInterval kFadeDelay = 0.5;

- (void)showImage:(NSImage *)image centeredInView:(NSView *)view; {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self window] setAlphaValue:1.0];
	
	[[self bezelView] setImage:image];
	
	NSRect frameRect = [[self window] frameRectForContentRect:[[self bezelView] frame]];
	NSRect centerRect = NSCenteredRectWithSize(frameRect.size, [[view window] convertRectToScreen:[view convertRectToBase:[view bounds]]]);
	centerRect.origin.y -= floor(NSHeight(centerRect)/2.0);
	
	[[self window] setFrame:centerRect display:YES];
	
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:kFadeDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}

- (void)showString:(NSString *)string centeredInView:(NSView *)view; {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self window] setAlphaValue:1.0];
	
	[[self bezelView] setString:string];
	
	NSRect frameRect = [[self window] frameRectForContentRect:[[self bezelView] frame]];
	NSRect centerRect = NSCenteredRectWithSize(frameRect.size, [[view window] convertRectToScreen:[view convertRectToBase:[view bounds]]]);
	centerRect.origin.y -= floor(NSHeight(centerRect)/2.0);
	
	[[self window] setFrame:centerRect display:YES];
	
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:kFadeDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
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
