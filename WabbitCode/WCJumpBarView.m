//
//  WCJumpBarView.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCJumpBarView.h"
#import "KBResponderNotifyingWindow.h"

@interface WCJumpBarView ()
- (void)_commonInit;
@end

@implementation WCJumpBarView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResignKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidBecomeKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_firstResponderDidChangeObservingToken];
	[_fillGradient release];
	[_alternateFillGradient release];
	[_bottomFillColor release];
	[_alternateBottomFillColor release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
    if (!(self = [super initWithFrame:frame]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSResponder *firstResponder = [[self window] firstResponder];
	
	if ([[self window] isKeyWindow] &&
		[firstResponder isKindOfClass:[NSView class]] &&
		[(NSView *)firstResponder isDescendantOf:[self superview]])
		[_fillGradient drawInRect:[self bounds] angle:90.0];
	else
		[_alternateFillGradient drawInRect:[self bounds] angle:90.0];
	
	if ([[self window] isKeyWindow] &&
		   [firstResponder isKindOfClass:[NSView class]] &&
		   [(NSView *)firstResponder isDescendantOf:[self superview]])
		[_bottomFillColor setFill];
	else
		[_alternateBottomFillColor setFill];
	
	NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResignKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidBecomeKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_firstResponderDidChangeObservingToken];
	
	if (newWindow) {
		_windowDidResignKeyObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
		_windowDidBecomeKeyObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
		
		if ([newWindow isKindOfClass:[KBResponderNotifyingWindow class]]) {
			_firstResponderDidChangeObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:KBWindowFirstResponderDidChangeNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
				[self setNeedsDisplay:YES];
			}];
		}
	}
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	_fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:174.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:211.0/255.0 alpha:1.0]];
	_alternateFillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:209.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:244.0/255.0 alpha:1.0]];
	_bottomFillColor = [[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0] retain];
	_alternateBottomFillColor = [[NSColor colorWithCalibratedWhite:109.0/255.0 alpha:1.0] retain];
}

@end
