//
//  WECalculatorWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WECalculatorWindowController.h"
#import "WECalculatorDocument.h"
#import "RSCalculator.h"
#import "RSLCDView.h"
#import "RSLCDViewManager.h"
#import "RSSkinView.h"
#import "RSDefines.h"

@interface WECalculatorWindowController ()
@property (readwrite,assign,nonatomic) RSLCDView *LCDView;
@property (readwrite,copy,nonatomic) NSString *statusString;
@end

@implementation WECalculatorWindowController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WECalculatorWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSView *contentView = [[self window] contentView];
	NSRect contentViewFrame = [contentView frame];
	RSCalculator *calculator = [[self calculatorDocument] calculator];
	NSSize skinSize = [[calculator skinImage] size];
	RSSkinView *skinView = [[[RSSkinView alloc] initWithFrame:NSMakeRect(contentViewFrame.origin.x, contentViewFrame.origin.y, skinSize.width, skinSize.height) calculator:calculator] autorelease];
	
	[[self window] setFrame:[[self window] frameRectForContentRect:NSMakeRect(0, 0, skinSize.width, skinSize.height+[[self window] contentBorderThicknessForEdge:NSMinYEdge])] display:YES];
	
	[contentView addSubview:skinView];
	
	NSRect skinViewFrame = [skinView frame];
	
	skinViewFrame.origin.y += [[self window] contentBorderThicknessForEdge:NSMinYEdge];
	
	[skinView setFrame:skinViewFrame];
	
	RSLCDView *lcdView = [[[RSLCDView alloc] initWithFrame:NSMakeRect(0, 0, 192, 128) calculator:calculator] autorelease];
	
	[skinView addSubview:lcdView];
	
	NSBitmapImageRep *bitmap = (NSBitmapImageRep *)[[calculator keymapImage] bestRepresentationForRect:NSZeroRect context:nil hints:nil];
	
	NSSize size = [bitmap size];
	NSUInteger width = size.width, height = size.height;
	NSUInteger i, j;
	NSUInteger pixels[4];
	NSPoint point = NSZeroPoint;
	NSPoint endPoint = NSZeroPoint;
	
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			[bitmap getPixel:pixels atX:i y:j];
			
			// red marks the start of the area for the lcd
			if (pixels[0] == 255 && pixels[1] == 0 && pixels[2] == 0) {
				point.x = i;
				point.y = j;
				
				while (pixels[0] == 255 && pixels[1] == 0 && pixels[2] == 0)
					[bitmap getPixel:pixels atX:i++ y:j];
				
				endPoint.x = i;
				i = point.x;
				
				[bitmap getPixel:pixels atX:i y:j];
				
				while (pixels[0] == 255 && pixels[1] == 0 && pixels[2] == 0)
					[bitmap getPixel:pixels atX:i y:j++];
				
				endPoint.y = j;
				break;
			}
		}
		
		if (!NSEqualPoints(point, NSZeroPoint))
			break;
	}
	
	[lcdView setFrame:NSMakeRect(point.x, point.y, endPoint.x-point.x, endPoint.y-point.y)];
	
	[[RSLCDViewManager sharedManager] addLCDView:lcdView];
	[self setLCDView:lcdView];
	
	_FPSTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_FPSTimerCallback:) userInfo:nil repeats:YES];
}

- (void)windowWillClose:(NSNotification *)notification {
	[_FPSTimer invalidate];
	_FPSTimer = nil;
	
	[[RSLCDViewManager sharedManager] removeLCDView:[self LCDView]];
}

- (id)initWithCalculatorDocument:(WECalculatorDocument *)calculatorDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_calculatorDocument = calculatorDocument;
	
	return self;
}

@synthesize calculatorDocument=_calculatorDocument;
@synthesize LCDView=_LCDView;
@synthesize statusString=_statusString;

- (void)_FPSTimerCallback:(NSTimer *)timer {
	RSCalculator *calculator = [[self calculatorDocument] calculator];
	
	if ([calculator isActive] && [calculator isRunning])
		[self setStatusString:[NSString stringWithFormat:NSLocalizedString(@"%@, FPS: %.2f", @"calculator status format string"),[calculator modelString],[calculator calculator]->cpu.pio.lcd->ufps]];
}

@end
