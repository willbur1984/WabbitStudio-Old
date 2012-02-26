//
//  RSLCDView.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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

@end
