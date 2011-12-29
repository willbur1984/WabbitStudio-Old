//
//  WCJumpBarView.h
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSView.h>

@interface WCJumpBarView : NSView {
	NSGradient *_fillGradient;
	NSGradient *_alternateFillGradient;
	NSColor *_bottomFillColor;
	NSColor *_alternateBottomFillColor;
	id _windowDidResignKeyObservingToken;
	id _windowDidBecomeKeyObservingToken;
}
@end
