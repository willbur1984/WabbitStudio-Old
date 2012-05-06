//
//  RSLCDView.h
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

#import <AppKit/NSOpenGLView.h>
#import <OpenGL/gl.h>
#import "RSTransferFileWindowControllerDelegate.h"

#define LCD_NORMAL_WIDTH 96
#define LCD_WIDESCREEN_WIDTH 128
#define LCD_HEIGHT 64
#define LCD_WIDTH_DISPLAY 192
#define LCD_WIDESCREEN_WIDTH_DISPLAY 256
#define LCD_HEIGHT_DISPLAY 128

@class RSCalculator,RSEmptyContentCell;

@interface RSLCDView : NSOpenGLView <RSTransferFileWindowControllerDelegate,NSDraggingDestination,NSDraggingSource> {
	uint8_t _buffer[LCD_HEIGHT][LCD_NORMAL_WIDTH][4];
	uint8_t _lcd_buffer[LCD_HEIGHT_DISPLAY][LCD_WIDTH_DISPLAY][4];
	uint8_t _wbuffer[LCD_HEIGHT][LCD_WIDESCREEN_WIDTH][4];
	uint8_t _wlcd_buffer[LCD_HEIGHT_DISPLAY][LCD_WIDESCREEN_WIDTH_DISPLAY][4];
	
	GLuint _buffer_texture;
	GLuint _lcd_texture;
	
	RSCalculator *_calculator;
	
	RSEmptyContentCell *_emptyContentCell;
}
@property (readwrite,retain,nonatomic) RSCalculator *calculator;
@property (readonly,nonatomic,getter = isWidescreen) BOOL widescreen;

- (id)initWithFrame:(NSRect)frameRect calculator:(RSCalculator *)calculator;

- (IBAction)loadRomOrSavestate:(id)sender;
- (IBAction)transferFiles:(id)sender;
- (IBAction)reloadCurrentRomOrSavestate:(id)sender;

- (IBAction)copy:(id)sender;

- (IBAction)toggleScreenRecording:(id)sender;

@end
