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
@property (readwrite,assign,nonatomic) BOOL isShowingToolTip;

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

- (void)mouseMoved:(NSEvent *)theEvent {
	if (!_currentView) {
		NSView *view = [[[theEvent window] contentView] hitTest:[theEvent locationInWindow]];
		if (![_viewsToTrackingAreas objectForKey:view])
			return;
		_currentView = (NSView <RSToolTipView> *)view;
	}
	
	NSArray *dataSources = [_currentView toolTipManager:self toolTipProvidersForToolTipAtPoint:[_currentView convertPointFromBase:[theEvent locationInWindow]]];
	
	if (dataSources) {
		if ([self isShowingToolTip])
			[self _showTooltipPanelForCurrentToolTipProvider];
		else if (_delayTimer)
			[_delayTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.35]];
		else
			_delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(_delayTimerCallback:) userInfo:nil repeats:NO];
	}
	else
		[self _closeToolTipPanelWithAnimation:YES];
}
#pragma mark NSAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag  {
	if ([self isShowingToolTip])
		return;
	else if (flag)
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
	
	NSParameterAssert([toolTipView window]);
	
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
		[_delayTimer invalidate];
		_delayTimer = nil;
		[NSEvent removeMonitor:_eventMonitor];
		_eventMonitor = nil;
	}
}
#pragma mark Properties
@synthesize textField=_textField;
@synthesize isShowingToolTip=_isShowingToolTip;
#pragma mark *** Private Methods ***
- (void)_showTooltipPanelForCurrentToolTipProvider; {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CAAnimation *animation = [CABasicAnimation animation];
		[animation setDuration:0.35];
		[animation setDelegate:self];
		[[self window] setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:animation,@"alphaValue", nil]];
	});
	
	_delayTimer = nil;
	
	NSEvent *theEvent = [NSApp currentEvent];
	NSArray *dataSources = [_currentView toolTipManager:self toolTipProvidersForToolTipAtPoint:[_currentView convertPointFromBase:[theEvent locationInWindow]]];
	
	if (dataSources) {
		[self setIsShowingToolTip:YES];
		
		NSMutableAttributedString *toolTip = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:RSToolTipProviderDefaultAttributes()] autorelease];
		for (id <RSToolTipProvider> dataSource in dataSources) {
			[toolTip appendAttributedString:[dataSource attributedToolTip]];
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
	if (![self isShowingToolTip])
		return;
	
	[self setIsShowingToolTip:NO];
	
	if (animate)
		[[[self window] animator] setAlphaValue:0.0];
	else
		[[self window] orderOut:nil];
}
#pragma mark Callbacks
- (void)_delayTimerCallback:(NSTimer *)timer {
	[_delayTimer invalidate];
	_delayTimer = nil;
	
	[self _showTooltipPanelForCurrentToolTipProvider];
}

@end
