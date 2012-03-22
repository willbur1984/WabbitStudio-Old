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
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	return self;
}

- (NSString *)windowNibName {
	return @"RSBezelWindow";
}

#pragma mark *** Public Methods ***
+ (RSBezelWidgetManager *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
		
		[[sharedInstance window] setAnimationBehavior:NSWindowAnimationBehaviorUtilityWindow];
	});
	return sharedInstance;
}

static const NSTimeInterval kFadeTimerDelay = 0.75;

- (void)showImage:(NSImage *)image centeredInView:(NSView *)view; {	
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self bezelView] setImage:image];
	
	NSRect frameRect = [[self window] frameRectForContentRect:[[self bezelView] frame]];
	NSRect centerRect = NSCenteredRectWithSize(frameRect.size, [[view window] convertRectToScreen:[view convertRectToBase:[view bounds]]]);
	centerRect.origin.y -= floor(NSHeight(centerRect)/2.0);
	
	[[self window] setFrame:centerRect display:YES];
	
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:kFadeTimerDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}

- (void)showString:(NSString *)string centeredInView:(NSView *)view; {	
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self bezelView] setString:string];
	
	NSRect frameRect = [[self window] frameRectForContentRect:[[self bezelView] frame]];
	NSRect centerRect = NSCenteredRectWithSize(frameRect.size, [[view window] convertRectToScreen:[view convertRectToBase:[view bounds]]]);
	centerRect.origin.y -= floor(NSHeight(centerRect)/2.0);
	
	[[self window] setFrame:centerRect display:YES];
	
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:kFadeTimerDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}
#pragma mark Properties
@synthesize bezelView=_bezelView;
#pragma mark *** Private Methods ***

#pragma mark Callbacks
- (void)_closeTimerCallback:(NSTimer *)timer {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self window] orderOut:nil];
}

@end
