#include <Cocoa/Cocoa.h>
#include <QuickLook/QuickLook.h>
#include "calc.h"

static NSString *const kWabbitEmuRomUTI = @"org.revsoft.wabbitemu.rom";

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	LPCALC calculator = calc_slot_new();
	
	if (!calculator) {
		[pool release];
		return noErr;
	}
	
	if (!rom_load(calculator, [[(NSURL *)url path] fileSystemRepresentation])) {
		[pool release];
		return noErr;
	}
	
	if ([(NSString *)contentTypeUTI isEqualToString:kWabbitEmuRomUTI])
		calc_turn_on(calculator);
	
	NSUInteger width = (calculator->model == TI_85 || calculator->model == TI_86)?256:192, height = 128;
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:width pixelsHigh:height bitsPerSample:8 samplesPerPixel:3 hasAlpha:NO isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0] autorelease];
	
	uint8_t *lcdptr = LCD_image(calculator->cpu.pio.lcd);
	uint16_t row, col;
	for (row=0; row<height; row++) {
		for (col=0; col<width; col++) {
			uint8_t val = 255-lcdptr[(row/2)*128+(col/2)];
			NSUInteger pixel[3] = {
				(0x9E*val)/255,
				(0xAB*val)/255,
				(0x88*val)/255
			};
			
			[bitmap setPixel:pixel atX:col y:row];
		}
	}
	
	NSData *data = [bitmap representationUsingType:NSPNGFileType properties:nil];
	
	QLThumbnailRequestSetImageWithData(thumbnail, (CFDataRef)data, NULL);
	
	calc_slot_free(calculator);
	
	[pool release];
	
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
