//
//  RSSkinView.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSSkinView.h"
#import "RSCalculator.h"
#import "RSDefines.h"

@interface RSSkinView ()
@property (readwrite,assign,nonatomic) NSPoint clickedPoint;
@end

@implementation RSSkinView

- (void)dealloc {
	[_calculator release];
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (![[self calculator] isActive] || ![[self calculator] isRunning]) {
		NSBeep();
		return;
	}
	
	NSImage *keymap = [[self calculator] keymapImage];
	NSBitmapImageRep *bitmap = (NSBitmapImageRep *)[keymap bestRepresentationForRect:NSZeroRect context:nil hints:nil];
	
#ifdef DEBUG
	NSAssert(bitmap, @"bitmap for keymap image was nil!");
#endif
	
	NSPoint point = [self convertPointFromBase:[theEvent locationInWindow]];
	NSUInteger rgba[4];
	
	[bitmap getPixel:rgba atX:point.x y:point.y];
	
	uint8_t group, bit;
	keypad_t *kp = [[self calculator] calculator]->cpu.pio.keypad;
	
	for(group=0;group<7;group++) {
		for(bit=0;bit<8;bit++) {
			kp->keys[group][bit] &=(~KEY_MOUSEPRESS);
		}
	}
	
	[[self calculator] calculator]->cpu.pio.keypad->on_pressed &= ~KEY_MOUSEPRESS;
	
	if (rgba[0] == 0xFF) {
		goto finalize_buttons;
	}
	
	if ((rgba[1]>>4) == 0x05 && (rgba[2]>>4) == 0x00) {
		[[self calculator] calculator]->cpu.pio.keypad->on_pressed |= KEY_MOUSEPRESS;
		
		[self setClickedPoint:point];
	}
	else {
		kp->keys[rgba[1] >> 4][rgba[2] >> 4] |= KEY_MOUSEPRESS;
		if ((kp->keys[rgba[1] >> 4][rgba[2] >> 4] & KEY_STATEDOWN) == 0) {
			//DrawButtonState(calcs[gslot].hdcSkin, calcs[gslot].hdcKeymap, &pt, DBS_DOWN | DBS_PRESS);
			kp->keys[rgba[1] >> 4][rgba[2] >> 4] |= KEY_STATEDOWN;
			//SendMessage(hwnd, WM_SIZE, 0, 0);
			
			[self setClickedPoint:point];
		}
	}
	
finalize_buttons:
	for(group=0;group<7;group++) {
		for(bit=0;bit<8;bit++) {
			if ((kp->keys[group][bit] & KEY_STATEDOWN) &&
				((kp->keys[group][bit] & KEY_MOUSEPRESS) == 0) &&
				((kp->keys[group][bit] & KEY_KEYBOARDPRESS) == 0)) {
				//DrawButtonState(calcs[gslot].hdcSkin, calcs[gslot].hdcKeymap, &ButtonCenter[bit+(group<<3)], DBS_UP | DBS_PRESS);
				kp->keys[group][bit] &= (~KEY_STATEDOWN);
				//SendMessage(hwnd, WM_SIZE, 0, 0);
				
				[self setClickedPoint:point];
			}
		}
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	NSImage *keymap = [[self calculator] keymapImage];
	
	if (!keymap) {
		NSLog(@"Unable to find keymap image!");
		return;
	}
	//NSBitmapImageRep *bitmap = (NSBitmapImageRep *)[keymap bestRepresentationForRect:NSZeroRect context:nil hints:nil];
	
#ifdef DEBUG
	NSAssert(keymap, @"keymap image was nil!");
#endif
	
	uint8_t group, bit;
	keypad_t *kp = [[self calculator] calculator]->cpu.pio.keypad;
	
	for(group=0;group<7;group++) {
		for(bit=0;bit<8;bit++) {
			kp->keys[group][bit] &=(~KEY_MOUSEPRESS);
		}
	}
	
	[[self calculator] calculator]->cpu.pio.keypad->on_pressed &= ~KEY_MOUSEPRESS;
	
	for(group=0;group<7;group++) {
		for(bit=0;bit<8;bit++) {
			if ((kp->keys[group][bit] & KEY_STATEDOWN) &&
				((kp->keys[group][bit] & KEY_MOUSEPRESS) == 0) &&
				((kp->keys[group][bit] & KEY_KEYBOARDPRESS) == 0)) {
				//DrawButtonState(calcs[gslot].hdcSkin, calcs[gslot].hdcKeymap, &ButtonCenter[bit+(group<<3)], DBS_UP | DBS_PRESS);
				kp->keys[group][bit] &= (~KEY_STATEDOWN);
				//SendMessage(hwnd, WM_SIZE, 0, 0);
			}
		}
	}
	
	[self setClickedPoint:NSZeroPoint];
}

- (BOOL)isFlipped {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[[self calculator] skinImage] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
	NSImage *keymap = [[self calculator] keymapImage];
	NSBitmapImageRep *bitmap = (NSBitmapImageRep *)[keymap bestRepresentationForRect:NSZeroRect context:nil hints:nil];
	NSSize bitmapSize = [bitmap size];
	NSPoint point = [self clickedPoint];
	NSUInteger rgba[4];
	
	[bitmap getPixel:rgba atX:point.x y:point.y];
	
	if (rgba[0] == 255 && rgba[1] == 255 && rgba[2] == 255)
		return;
	
	NSUInteger xPos, yPos, width, height;
	NSInteger pIndex;
	
	// find the left edge
	for (pIndex=point.x; pIndex>=0; pIndex--) {
		[bitmap getPixel:rgba atX:pIndex y:point.y];
		
		if (rgba[0] == 255 && rgba[1] == 255 && rgba[2] == 255) {
			xPos = pIndex;
			break;
		}
	}
	
	// find the right edge
	for (pIndex=point.x; pIndex<bitmapSize.width; pIndex++) {
		[bitmap getPixel:rgba atX:pIndex y:point.y];
		
		if (rgba[0] == 255 && rgba[1] == 255 && rgba[2] == 255) {
			width = pIndex - xPos;
			break;
		}
	}
	
	// find the top edge
	for (pIndex=point.y; pIndex>=0; pIndex--) {
		[bitmap getPixel:rgba atX:point.x y:pIndex];
		
		if (rgba[0] == 255 && rgba[1] == 255 && rgba[2] == 255) {
			yPos = pIndex;
			break;
		}
	}
	
	// find the bottom edge
	for (pIndex=point.y; pIndex<bitmapSize.height; pIndex++) {
		[bitmap getPixel:rgba atX:point.x y:pIndex];
		
		if (rgba[0] == 255 && rgba[1] == 255 && rgba[2] == 255) {
			height = pIndex - yPos;
			break;
		}
	}
	
	NSRect buttonRect = NSMakeRect(xPos, yPos, width, height);
	
	[[[NSColor blackColor] colorWithAlphaComponent:0.5] setFill];
	[[NSBezierPath bezierPathWithRoundedRect:buttonRect xRadius:10.0 yRadius:10.0] fill];
}

- (id)initWithFrame:(NSRect)frameRect calculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self setAutoresizingMask:NSViewNotSizable];
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;
@synthesize clickedPoint=_clickedPoint;
- (void)setClickedPoint:(NSPoint)clickedPoint {
	if (NSEqualPoints(_clickedPoint, clickedPoint))
		return;
	
	_clickedPoint = clickedPoint;
	
	[self setNeedsDisplay:YES];
}

@end
