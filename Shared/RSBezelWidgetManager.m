//
//  RSBezelWindowController.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

static const NSTimeInterval kImageFadeTimerDelay = 0.5;
static const NSTimeInterval kStringFadeTimerDelay = 1.0;

- (void)showImage:(NSImage *)image centeredInView:(NSView *)view; {	
	[self showImage:image centeredInView:view withCloseDelay:kImageFadeTimerDelay];
}

- (void)showString:(NSString *)string centeredInView:(NSView *)view; {	
	[self showString:string centeredInView:view withCloseDelay:kStringFadeTimerDelay];
}

- (void)showImage:(NSImage *)image centeredInView:(NSView *)view withCloseDelay:(NSTimeInterval)closeDelay; {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self bezelView] setImage:image];
	
	NSRect frameRect = [[self window] frameRectForContentRect:[[self bezelView] frame]];
	NSRect centerRect = NSCenteredRectWithSize(frameRect.size, [[view window] convertRectToScreen:[view convertRectToBase:[view bounds]]]);
	centerRect.origin.y -= floor(NSHeight(centerRect)/2.0);
	
	[[self window] setFrame:centerRect display:YES];
	
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:closeDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}
- (void)showString:(NSString *)string centeredInView:(NSView *)view withCloseDelay:(NSTimeInterval)closeDelay; {
	[_fadeTimer invalidate];
	_fadeTimer = nil;
	
	[[self bezelView] setString:string];
	
	NSRect frameRect = [[self window] frameRectForContentRect:[[self bezelView] frame]];
	NSRect centerRect = NSCenteredRectWithSize(frameRect.size, [[view window] convertRectToScreen:[view convertRectToBase:[view bounds]]]);
	centerRect.origin.y -= floor(NSHeight(centerRect)/2.0);
	
	[[self window] setFrame:centerRect display:YES];
	
	[[self window] orderFront:nil];
	
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:closeDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
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
