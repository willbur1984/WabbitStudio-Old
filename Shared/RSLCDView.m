//
//  RSLCDView.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSLCDView.h"
#import "RSCalculator.h"
#import "RSDefines.h"
#import "RSTransferFileWindowController.h"
#import "RSEmptyContentCell.h"
#import "RSGifRecordingStatusView.h"
#include "gif.h"

@interface RSLCDView ()
@property (readonly,nonatomic) NSBitmapImageRep *LCDBitmap;

- (void)_commonInit;
@end

@implementation RSLCDView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_emptyContentCell release];
	[_calculator release];
	glDeleteTextures(1, &_buffer_texture);
	glDeleteTextures(1, &_lcd_texture);
	[super dealloc];
}

- (BOOL)acceptsFirstResponder {
	return ([[self calculator] isActive] && [[self calculator] isRunning]);
}

- (void)keyDown:(NSEvent *)theEvent {
	CPU_t *cpu = &([[self calculator] calculator]->cpu);
	
	keypad_key_press(cpu, [theEvent keyCode], NULL);
}

- (void)keyUp:(NSEvent *)theEvent {
	CPU_t *cpu = &([[self calculator] calculator]->cpu);
	
	keypad_key_release(cpu, [theEvent keyCode]);
}

- (void)mouseDragged:(NSEvent *)theEvent {
	NSString *directoryPath = NSTemporaryDirectory();
	NSString *fileName = NSLocalizedString(@"screenshot", @"screenshot");
	//NSString *fileName = [[NSUserDefaults standardUserDefaults] stringForKey:kWEPrefsScreenShotsFileNameKey];
	NSBitmapImageFileType fileType = NSPNGFileType;
	//NSBitmapImageFileType fileType = [[NSUserDefaults standardUserDefaults] unsignedIntegerForKey:kWEPrefsScreenShotsFormatKey];
	NSString *fileExtension = @"png";
	//NSString *fileExtension = [[WEBasicPerformer sharedInstance] fileExtensionForBitmapImageFileType:fileType];
	NSURL *fileURL = [[NSURL fileURLWithPath:directoryPath isDirectory:YES] URLByAppendingPathComponent:[fileName stringByAppendingPathExtension:fileExtension]];
	
	// grab our bitmap rep
	NSBitmapImageRep *bitmap = [self LCDBitmap];
	// get it's data
	NSData *bitmapData = [bitmap representationUsingType:fileType properties:nil];
	// get the point for this event, and the drag point which is centered on the image
	NSPoint dragPoint, location = [self convertPointFromBase:[theEvent locationInWindow]];
	dragPoint.x = location.x - [bitmap size].width/2;
	dragPoint.y = location.y - [bitmap size].height/2;
	// the image that will be dragged
	NSImage *dragImage = [[[NSImage alloc] initWithSize:[bitmap size]] autorelease];
	// temp image used to draw into the drag image
	NSImage *tempImage = [[[NSImage alloc] initWithSize:[bitmap size]] autorelease];
	[tempImage addRepresentation:bitmap];
	[dragImage lockFocus];
	// draw with partial transparency
	[tempImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:0.85];
	[dragImage unlockFocus];
	
	// write our temporary file to disk
	if (![bitmapData writeToURL:fileURL options:NSDataWritingAtomic error:NULL])
		return;
	
	NSDraggingItem *dragItem = [[[NSDraggingItem alloc] initWithPasteboardWriter:fileURL] autorelease];
	
	[dragItem setImageComponentsProvider:^NSArray *{
		NSDraggingImageComponent *imageComponent = [[[NSDraggingImageComponent alloc] initWithKey:NSDraggingImageComponentIconKey] autorelease];
		
		[imageComponent setContents:tempImage];
		[imageComponent setFrame:NSMakeRect(dragPoint.x, dragPoint.y, [bitmap size].width, [bitmap size].height)];
		
		return [NSArray arrayWithObjects:imageComponent, nil];
		
	}];
	
	[self beginDraggingSessionWithItems:[NSArray arrayWithObjects:dragItem, nil] event:theEvent source:self];
}

+ (NSMenu *)defaultMenu {
	static NSMenu *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSMenu alloc] initWithTitle:@""];
		
		[retval addItemWithTitle:NSLocalizedString(@"Load Rom or Savestate\u2026", @"Load Rom or Savestate with ellipsis") action:@selector(loadRomOrSavestate:) keyEquivalent:@""];
		[retval addItemWithTitle:NSLocalizedString(@"Transfer Files\u2026", @"Transfer Files with ellipsis") action:@selector(transferFiles:) keyEquivalent:@""];
		[retval addItem:[NSMenuItem separatorItem]];
		[retval addItemWithTitle:NSLocalizedString(@"Reload Current Rom or Savestate", @"Reload Current Rom or Savestate") action:@selector(reloadCurrentRomOrSavestate:) keyEquivalent:@""];
	});
	return retval;
}

- (BOOL)isOpaque {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if ([[self calculator] isActive] && [[self calculator] isRunning]) {
		glClear(GL_COLOR_BUFFER_BIT);
		// enable blend so we can put the lcd pattern over the raw image
		glEnable(GL_BLEND);
		
		// grab the lcd data from wabbit
		uint8_t *lcdImage = LCD_image([[self calculator] calculator]->cpu.pio.lcd);
		uint16_t row, col;
		
		// pretty up the colors a bit, this makes the lcd have its green tint
		if ([self isWidescreen]) {
			for (row=0; row<LCD_HEIGHT; row++) {
				for (col=0; col<LCD_WIDESCREEN_WIDTH; col++) {
					uint8_t val = 255-lcdImage[row*LCD_WIDESCREEN_WIDTH+col];
					
					_wbuffer[row][col][2] = (0x9E*val)/255;
					_wbuffer[row][col][1] = (0xAB*val)/255;
					_wbuffer[row][col][0] = (0x88*val)/255;
				}
			}
		}
		else {
			for (row=0; row<LCD_HEIGHT; row++) {
				for (col=0; col<LCD_NORMAL_WIDTH; col++) {
					u_char val = 255-lcdImage[(row)*LCD_WIDESCREEN_WIDTH+(col)];
					
					_buffer[row][col][2] = (0x9E*val)/255;
					_buffer[row][col][1] = (0xAB*val)/255;
					_buffer[row][col][0] = (0x88*val)/255;
				}
			}
		}
		
		CGFloat width = ([self isWidescreen])?LCD_WIDESCREEN_WIDTH:LCD_NORMAL_WIDTH;
		CGFloat height = LCD_HEIGHT;
		
		// bind to our texture for the lcd data
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _buffer_texture);
		glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_SHARED_APPLE);
		glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glPixelStoref(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
		
		// pull from the right buffer depending on widescreen status
		if ([self isWidescreen])
			glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _wbuffer);
		else
			glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _buffer);
		
		// paint our quad covering our entire bounds
		glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex2f(-1.0f, 1.0f);
		glTexCoord2f(0.0f, height );
		glVertex2f(-1.0f, -1.0f);
		glTexCoord2f(width, height );
		glVertex2f(1.0f, -1.0f);
		glTexCoord2f(width, 0.0f );
		glVertex2f(1.0f, 1.0f);
		glEnd();
		
		// bind to our texture the lcd wire pattern
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, _lcd_texture);
		glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_CACHED_APPLE);
		glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glPixelStoref(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
		
		// pull from the right buffer depending on widescreen status
		if ([self isWidescreen])
			glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, LCD_WIDESCREEN_WIDTH_DISPLAY, LCD_HEIGHT_DISPLAY, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _wlcd_buffer);
		else
			glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, LCD_WIDTH_DISPLAY, LCD_HEIGHT_DISPLAY, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _lcd_buffer);
		
		// paint our quad covering our entire bounds
		glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex2f(-1.0f, 1.0f);
		glTexCoord2f(0.0f, height );
		glVertex2f(-1.0f, -1.0f);
		glTexCoord2f(width, height );
		glVertex2f(1.0f, -1.0f);
		glTexCoord2f(width, 0.0f );
		glVertex2f(1.0f, 1.0f);
		glEnd();
		
		// blend the wire pattern on top of the lcd image
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		// match the glEnable(GL_BLEND); call earlier
		glDisable(GL_BLEND);
		
		glFinish();
	}
	else {
		[[NSColor controlBackgroundColor] setFill];
		NSRectFill([self bounds]);
		
		[_emptyContentCell drawWithFrame:[self bounds] inView:self];
	}
}

- (void)prepareOpenGL {
	[super prepareOpenGL];
	
	glClearColor(0.0, 0.0, 0.0, 0.0);
	
	// enable rectangular textures
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	
	// disable all the junk we dont need
	glDisable(GL_DITHER);
	glDisable(GL_ALPHA_TEST);
	glDisable(GL_STENCIL_TEST);
	glDisable(GL_FOG);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	
	// create our two textures, one for the lcd image, another for the lcd wire pattern
	glGenTextures(1, &_buffer_texture);
	glGenTextures(1, &_lcd_texture);
}

- (void)reshape {
	// comment this out to see something interesting when you have more than one calc open and resize
	[[self openGLContext] makeCurrentContext];
	
	// reset our viewport to match the view's bounds
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glViewport(0.0,0.0,NSWidth([self bounds]),NSHeight([self bounds]));
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(toggleScreenRecording:)) {
		if (gif_write_state == GIF_IDLE)
			[menuItem setTitle:NSLocalizedString(@"Start Recording Screen", @"Start Recording Screen")];
		else
			[menuItem setTitle:NSLocalizedString(@"Stop Recording Screen", @"Stop Recording Screen")];
	}
	return YES;
}

#pragma mark NSDraggingDestination
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)info {
	if ([info draggingSource] == self)
		return NSDragOperationNone;
	
	NSArray *fileURLs = [[info draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObjects:[NSURL class], nil] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey, nil]];
	NSArray *acceptedFileURLs = [RSTransferFileWindowController filterTransferFileURLs:fileURLs];
	
	if ([acceptedFileURLs count])
		return NSDragOperationCopy;
	
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)info {
	NSArray *fileURLs = [[info draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObjects:[NSURL class], nil] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey, nil]];
	RSTransferFileWindowController *transferFileWindowController = [[[RSTransferFileWindowController alloc] initWithCalculator:[self calculator]] autorelease];
	
	[transferFileWindowController setDelegate:self];
	
	[transferFileWindowController showTransferFileWindowForTransferFileURLs:[RSTransferFileWindowController filterTransferFileURLs:fileURLs]];
	
	return YES;
}

- (void)draggingEnded:(id<NSDraggingInfo>)info {

}
#pragma mark NSDraggingSource
- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context; {
	return NSDragOperationCopy;
}
- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
	
}
#pragma mark RSTransferFileWindowControllerDelegate
- (NSWindow *)windowForTransferFileWindowControllerSheet:(RSTransferFileWindowController *)transferFileWindowController {
	return [self window];
}
#pragma mark *** Public Methods ***
- (id)initWithFrame:(NSRect)frameRect calculator:(RSCalculator *)calculator; {
	const NSOpenGLPixelFormatAttribute pixelFormatAttributes[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFAAuxBuffers,0,
		NSOpenGLPFADepthSize,0,
		NSOpenGLPFAStencilSize,0,
		NSOpenGLPFAColorSize,32,
		NSOpenGLPFAAccumSize,0,
		0
	};
	NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes] autorelease];
	
	if (!(self = [super initWithFrame:frameRect pixelFormat:pixelFormat]))
		return nil;
	
	[self setAutoresizingMask:NSViewNotSizable];
	
	_calculator = [calculator retain];
	
	[self _commonInit];
	
	return self;
}
#pragma mark IBActions
- (IBAction)loadRomOrSavestate:(id)sender; {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:RSCalculatorRomUTI,RSCalculatorSavestateUTI, nil]];
	[openPanel setPrompt:LOCALIZED_STRING_LOAD];
	
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		NSError *outError;
		if (![[self calculator] loadRomOrSavestateAtURL:[[openPanel URLs] lastObject] error:&outError]) {
			[openPanel orderOut:nil];
			[[self window] presentError:outError];
		}
	}];
}
- (IBAction)transferFiles:(id)sender; {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:RSCalculatorProgramUTI,RSCalculatorApplicationUTI,RSCalculatorGroupFileUTI,RSCalculatorPictureFileUTI, nil]];
	[openPanel setPrompt:NSLocalizedString(@"Transfer", @"Transfer")];
	[openPanel setAllowsMultipleSelection:YES];
	
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		[openPanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		RSTransferFileWindowController *transferFileWindowController = [[[RSTransferFileWindowController alloc] initWithCalculator:[self calculator]] autorelease];
		
		[transferFileWindowController setDelegate:self];
		
		[transferFileWindowController showTransferFileWindowForTransferFileURLs:[RSTransferFileWindowController filterTransferFileURLs:[openPanel URLs]]];
	}];
}
- (IBAction)reloadCurrentRomOrSavestate:(id)sender; {
	[[self calculator] reloadLastRomOrSavestate];
}

- (IBAction)copy:(id)sender; {
	if (![[self calculator] isActive]) {
		NSBeep();
		return;
	}
	
	char *answerString = GetRealAns(&([[self calculator] calculator]->cpu));
	if (answerString && strlen(answerString)) {
		NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];
		
		[pboard clearContents];
		[pboard writeObjects:[NSArray arrayWithObjects:[[[NSString alloc] initWithCString:answerString encoding:NSUTF8StringEncoding] autorelease], nil]];
		
		free(answerString);
	}
}

- (IBAction)toggleScreenRecording:(id)sender; {
	
	
	RSGifRecordingStatusView *gifView = nil;
	
	for (id subview in [[[self window] contentView] subviews]) {
		if ([subview isKindOfClass:[RSGifRecordingStatusView class]]) {
			gifView = subview;
			break;
		}
	}
	
	if (gifView) {
		NSRect gifViewFrame = [gifView frame];
		
		[[gifView animator] setFrameOrigin:NSMakePoint(NSMinX(gifViewFrame), NSMinY(gifViewFrame)+NSHeight(gifViewFrame))];
		
		[gifView performSelector:@selector(removeFromSuperviewWithoutNeedingDisplay) withObject:nil afterDelay:0.35];
		
		calc_stop_screenshot([[self calculator] calculator]);
	}
	else {
		NSView *contentView = [[self window] contentView];
		NSRect contentViewFrame = [contentView frame];
		
		gifView = [[[RSGifRecordingStatusView alloc] initWithFrame:NSMakeRect(NSMinX(contentViewFrame), NSMaxY(contentViewFrame), NSWidth(contentViewFrame), 23.0)] autorelease];
		
		[contentView addSubview:gifView positioned:NSWindowAbove relativeTo:[self superview]];
		
		NSRect gifViewFrame = [gifView frame];
		NSString *screenshotPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:@"screenshot.gif"];
		
		[gifView setStatusString:[NSString stringWithFormat:NSLocalizedString(@"Recording (%@)\u2026", @"screenshot status format string"),screenshotPath]];
		[[gifView animator] setFrameOrigin:NSMakePoint(NSMinX(gifViewFrame), NSMinY(gifViewFrame)-NSHeight(gifViewFrame))];
		
		calc_start_screenshot([[self calculator] calculator], [screenshotPath fileSystemRepresentation]);
	}
}
#pragma mark Properties
@synthesize calculator=_calculator;
@dynamic widescreen;
- (BOOL)isWidescreen {
	return ([[self calculator] model] == RSCalculatorModelTI_85 || [[self calculator] model] == RSCalculatorModelTI_86);
}
@dynamic LCDBitmap;
- (NSBitmapImageRep *)LCDBitmap {
	NSUInteger width = ([self isWidescreen])?LCD_WIDESCREEN_WIDTH_DISPLAY:LCD_WIDTH_DISPLAY;
	NSUInteger height = LCD_HEIGHT_DISPLAY;
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:width pixelsHigh:height bitsPerSample:8 samplesPerPixel:3 hasAlpha:NO isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0] autorelease];
	
	uint8_t *lcdData = LCD_image([[self calculator] calculator]->cpu.pio.lcd);
	uint16_t row, col;
	for (row=0; row<height; row++) {
		for (col=0; col<width; col++) {
			uint8_t val = 255-lcdData[(row/2)*LCD_WIDESCREEN_WIDTH+(col/2)];
			NSUInteger pixel[3];
			
			pixel[2] = val;
			pixel[1] = val;
			pixel[0] = val;
			
			[bitmap setPixel:pixel atX:col y:row];
		}
	}
	return bitmap;
}
#pragma mark *** Private Methods ***
- (void)_commonInit {
	[self registerForDraggedTypes:[NSArray arrayWithObjects:(NSString *)kUTTypeFileURL, nil]];
	
	_emptyContentCell = [[RSEmptyContentCell alloc] initTextCell:NSLocalizedString(@"No Calculator", @"No Calculator")];
	[_emptyContentCell setEmptyContentStringStyle:RSEmptyContentStringStyleNormal];
	
	uint16_t row, col;
	for (row=0; row<LCD_HEIGHT; row++) {
		for (col=0; col<LCD_NORMAL_WIDTH; col++) {
			// alpha channel is always the same, set it once and forget it, while the lcd doesn't have an alpha channel, opengl requires it for textures
			_buffer[row][col][3] = 255;
		}
	}
	
	for (row=0; row<LCD_HEIGHT_DISPLAY; row++) {
		for (col=0; col<LCD_WIDTH_DISPLAY; col++) {
			if (col%2 == 0 && row%2 == 0) {
				_lcd_buffer[row][col][2] = 158;
				_lcd_buffer[row][col][1] = 171;
				_lcd_buffer[row][col][0] = 136;
			}
			else if (col%2 == 1 && row%2 == 1) {
				_lcd_buffer[row][col][2] = 126;
				_lcd_buffer[row][col][1] = 137;
				_lcd_buffer[row][col][0] = 109;
			}
			else {
				_lcd_buffer[row][col][2] = 142;
				_lcd_buffer[row][col][1] = 154;
				_lcd_buffer[row][col][0] = 122;
			}
			// alpha channel is always the same, set it once and forget it, while the lcd doesn't have an alpha channel, opengl requires it for textures
			_lcd_buffer[row][col][3] = 108;
		}
	}
	
	for (row=0; row<LCD_HEIGHT; row++) {
		for (col=0; col<LCD_WIDESCREEN_WIDTH; col++) {
			// alpha channel is always the same, set it once and forget it, while the lcd doesn't have an alpha channel, opengl requires it for textures
			_wbuffer[row][col][3] = 255;
		}
	}
	
	for (row=0; row<LCD_HEIGHT_DISPLAY; row++) {
		for (col=0; col<LCD_WIDESCREEN_WIDTH_DISPLAY; col++) {
			if (col%2 == 0 && row%2 == 0) {
				_wlcd_buffer[row][col][2] = 158;
				_wlcd_buffer[row][col][1] = 171;
				_wlcd_buffer[row][col][0] = 136;
			}
			else if (col%2 == 1 && row%2 == 1) {
				_wlcd_buffer[row][col][2] = 126;
				_wlcd_buffer[row][col][1] = 137;
				_wlcd_buffer[row][col][0] = 109;
			}
			else {
				_wlcd_buffer[row][col][2] = 142;
				_wlcd_buffer[row][col][1] = 154;
				_wlcd_buffer[row][col][0] = 122;
			}
			// alpha channel is always the same, set it once and forget it, while the lcd doesn't have an alpha channel, opengl requires it for textures
			_wlcd_buffer[row][col][3] = 108;
		}
	}
}

@end
