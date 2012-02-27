//
//  RSGifRecordingStatusView.m
//  WabbitStudio
//
//  Created by William Towe on 2/27/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSGifRecordingStatusView.h"
#import "RSDefines.h"
#import "RSVerticallyCenteredTextFieldCell.h"

@implementation RSGifRecordingStatusView

- (void)dealloc {
	[_textFieldCell release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	_textFieldCell = [[RSVerticallyCenteredTextFieldCell alloc] initTextCell:@""];
	[_textFieldCell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[_textFieldCell setBackgroundStyle:NSBackgroundStyleLowered];
	[_textFieldCell setTextColor:[NSColor whiteColor]];
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *gradient;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.75 green:0.0 blue:0.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0]];
	});
	
	[gradient drawInRect:[self bounds] angle:270.0];
	
	[[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0] setFill];
	NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
	
	[_textFieldCell setStringValue:[self statusString]];
	[_textFieldCell drawWithFrame:NSInsetRect([self bounds], 8.0, 0.0) inView:self];
}

@synthesize statusString=_statusString;
- (void)setStatusString:(NSString *)statusString {
	if (_statusString == statusString)
		return;
	
	[_statusString release];
	_statusString = [statusString copy];
	
	[self setNeedsDisplay:YES];
}

@end
