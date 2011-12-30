//
//  RSToolTipManager.m
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSToolTipManager.h"
#import <QuartzCore/QuartzCore.h>
#import "RSToolTipProvider.h"

@interface RSToolTipManager ()

- (void)_showTooltipPanelForCurrentToolTipProvider;
- (void)_closeToolTipPanelWithAnimation:(BOOL)animate;
@end

@implementation RSToolTipManager
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:_applicationDidResignActiveObservingToken];
	[NSEvent removeMonitor:_eventMonitor];
	[_viewsToTrackingAreas release];
	[_trackingAreasToViews release];
    [super dealloc];
}

- (id)initWithWindow:(NSWindow *)window {
	if (!(self = [super initWithWindow:window]))
		return nil;
	
	_viewsToTrackingAreas = [[NSMapTable mapTableWithWeakToWeakObjects] retain];
	_trackingAreasToViews = [[NSMapTable mapTableWithWeakToWeakObjects] retain];
	
	return self;
}

- (void)mouseEntered:(NSEvent *)theEvent {
	_currentView = nil;
	[self _closeToolTipPanelWithAnimation:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	_currentView = nil;
	[self _closeToolTipPanelWithAnimation:YES];
}

static const NSTimeInterval kShowToolTipDelay = 0.35;
static const NSTimeInterval kCloseToolTipDelay = 0.25;

- (void)mouseMoved:(NSEvent *)theEvent {
	if (!_currentView) {
		NSView *view = [[[theEvent window] contentView] hitTest:[theEvent locationInWindow]];
		if (![_viewsToTrackingAreas objectForKey:view])
			return;
		_currentView = (NSView <RSToolTipView> *)view;
	}
	
	NSArray *dataSources = [_currentView toolTipManager:self toolTipProvidersForToolTipAtPoint:[_currentView convertPointFromBase:[theEvent locationInWindow]]];
	
	if (dataSources) {
		[_closeTimer invalidate];
		_closeTimer = nil;
		
		if ([[self window] isVisible])
			[self _showTooltipPanelForCurrentToolTipProvider];
		else if (_showTimer)
			[_showTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kShowToolTipDelay]];
		else
			_showTimer = [NSTimer scheduledTimerWithTimeInterval:kShowToolTipDelay target:self selector:@selector(_showTimerCallback:) userInfo:nil repeats:NO];
	}
	else if (_closeTimer)
		[_closeTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kCloseToolTipDelay]];
	else
		_closeTimer = [NSTimer scheduledTimerWithTimeInterval:kCloseToolTipDelay target:self selector:@selector(_closeTimerCallback:) userInfo:nil repeats:NO];
}
#pragma mark NSAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag  {
	if (flag)
		[[self window] orderOut:nil];
}
#pragma mark *** Public Methods ***
+ (RSToolTipManager *)sharedManager {
	static RSToolTipManager *toolTipManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		toolTipManager = [[RSToolTipManager alloc] initWithWindowNibName:@"RSToolTipWindow"];
	});
	return toolTipManager;
}

- (void)addView:(NSView <RSToolTipView> *)toolTipView {
	if ([_viewsToTrackingAreas objectForKey:toolTipView])
		return;
	
	if (![_viewsToTrackingAreas count]) {
		_eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask|NSKeyDownMask|NSScrollWheelMask handler:^NSEvent* (NSEvent *event) {
			switch ([event type]) {
				case NSLeftMouseDown:
				case NSRightMouseDown:
				case NSKeyDown:
				case NSScrollWheel:
					[self _closeToolTipPanelWithAnimation:NO];
					break;
				default:
					break;
			}
			return event;
		}];
		
		_applicationDidResignActiveObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidResignActiveNotification object:NSApp queue:nil usingBlock:^(NSNotification *note) {
			[self _closeToolTipPanelWithAnimation:NO];
		}];
	}
	
#ifdef DEBUG
    NSAssert([toolTipView window], @"toolTipView %@ must have a window!",toolTipView);
#endif
	
	NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited owner:self userInfo:nil] autorelease];
	
	[_viewsToTrackingAreas setObject:trackingArea forKey:toolTipView];
	[_trackingAreasToViews setObject:toolTipView forKey:trackingArea];
	[toolTipView addTrackingArea:trackingArea];
}
- (void)removeView:(NSView <RSToolTipView> *)toolTipView {
	if (![_viewsToTrackingAreas objectForKey:toolTipView])
		return;
	
	_currentView = nil;
	
	NSTrackingArea *trackingArea = [_viewsToTrackingAreas objectForKey:toolTipView];
	[_viewsToTrackingAreas removeObjectForKey:toolTipView];
	[_trackingAreasToViews removeObjectForKey:trackingArea];
	[toolTipView removeTrackingArea:trackingArea];
	
	if (![_viewsToTrackingAreas count]) {
		[[NSNotificationCenter defaultCenter] removeObserver:_applicationDidResignActiveObservingToken];
		[_showTimer invalidate];
		_showTimer = nil;
		[_closeTimer invalidate];
		_closeTimer = nil;
		[NSEvent removeMonitor:_eventMonitor];
		_eventMonitor = nil;
	}
}
#pragma mark Properties
@synthesize textField=_textField;
#pragma mark *** Private Methods ***
- (void)_showTooltipPanelForCurrentToolTipProvider; {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CAAnimation *animation = [CABasicAnimation animation];
		[animation setDuration:0.35];
		[animation setDelegate:self];
		[[self window] setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:animation,@"alphaValue", nil]];
	});
	
	NSEvent *theEvent = [NSApp currentEvent];
	NSArray *providers = [_currentView toolTipManager:self toolTipProvidersForToolTipAtPoint:[_currentView convertPointFromBase:[theEvent locationInWindow]]];
	
	if (providers) {
		NSMutableAttributedString *toolTip = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:RSToolTipProviderDefaultAttributes()] autorelease];
		for (id <RSToolTipProvider> provider in providers) {
			[toolTip appendAttributedString:[provider attributedToolTip]];
			[toolTip appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n" attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
		}
		
		// delete the trailing newline character
		[toolTip deleteCharactersInRange:NSMakeRange([toolTip length]-1, 1)];
		
		[[self textField] setAttributedStringValue:toolTip];
		[[self textField] sizeToFit];
		
		static const CGFloat kToolTipPaddingLeftRight = 8.0;
		static const CGFloat kToolTipPaddingTopBottom = 4.0;
		
		NSRect textFieldFrame = [[self textField] frame];
		
		[[self textField] setFrameOrigin:NSMakePoint(kToolTipPaddingLeftRight/2.0, kToolTipPaddingTopBottom/2.0)];
		
		textFieldFrame.size.width += kToolTipPaddingLeftRight;
		textFieldFrame.size.height += kToolTipPaddingTopBottom;
		
		NSRect frameRect = [[self window] frameRectForContentRect:textFieldFrame];
		frameRect.origin = [[theEvent window] convertBaseToScreen:[theEvent locationInWindow]];
		frameRect.origin.y -= (NSHeight(frameRect)+[[[NSCursor currentSystemCursor] image] size].height);
		
		[[self window] setFrame:frameRect display:YES];
		[[self window] setAlphaValue:1.0];
		[[self window] orderFront:nil];
	}
	else
		[self _closeToolTipPanelWithAnimation:YES];
}

- (void)_closeToolTipPanelWithAnimation:(BOOL)animate; {
	_currentView = nil;
	
	if (animate)
		[[[self window] animator] setAlphaValue:0.0];
	else
		[[self window] orderOut:nil];
}
#pragma mark Callbacks
- (void)_showTimerCallback:(NSTimer *)timer {
	[_showTimer invalidate];
	_showTimer = nil;
	
	[self _showTooltipPanelForCurrentToolTipProvider];
}
- (void)_closeTimerCallback:(NSTimer *)timer {
	[_closeTimer invalidate];
	_closeTimer = nil;
	
	[self _closeToolTipPanelWithAnimation:YES];
}

@end
