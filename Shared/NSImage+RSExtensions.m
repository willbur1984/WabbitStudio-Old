//
//  NSImage+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 7/22/11.
//  Copyright 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSImage+RSExtensions.h"
#import "RSDefines.h"
#import <QuartzCore/CIFilter.h>
#import <QuartzCore/CIVector.h>

@implementation NSImage (NSImage_RSExtensions)
// returns a new image that is darker than the original; similar to the unsaved image icons in Xcode
// this was adapted from the Smultron (now Fraise) source code
- (NSImage *)unsavedImageFromImage; {
	return [self darkenedImageWithBrightnessReduction:-0.5];
}
- (NSImage *)darkenedImageWithBrightnessReduction:(CGFloat)brightness; {
	NSImage *returnImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	NSArray *array = [NSBitmapImageRep imageRepsWithData:[self TIFFRepresentation]];
	for (id item in array) {
		CIImage *coreImage = [[[CIImage alloc] initWithBitmapImageRep:item] autorelease];
		
		CIFilter *filter1 = [CIFilter filterWithName:@"CIColorControls"]; 
		[filter1 setDefaults]; 
		[filter1 setValue:coreImage forKey:@"inputImage"];  
		[filter1 setValue:[NSNumber numberWithDouble:brightness] forKey:@"inputBrightness"];
		
		CIImage *result = [filter1 valueForKey:@"outputImage"];
		
		[returnImage addRepresentation:[NSCIImageRep imageRepWithCIImage:result]];
	}
	return returnImage;
}

- (NSImage *)badgedImageWithImage:(NSImage *)badgeImage badgePosition:(WCImageBadgePosition)badgePosition; {
	return [self badgedImageOfSize:NSSmallSize badgeImage:badgeImage badgeSize:NSMakeSize(8.0, 8.0) badgePosition:badgePosition];
}

- (NSImage *)badgedImageOfSize:(NSSize)imageSize badgeImage:(NSImage *)badgeImage badgeSize:(NSSize)badgeSize badgePosition:(WCImageBadgePosition)badgePosition; {
	NSImage *retval = [[[NSImage alloc] initWithSize:imageSize] autorelease];
	NSRect rect = NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height);
	NSRect badgeRect = NSZeroRect;
	
	switch (badgePosition) {
		case WCImageBadgePositionUpperLeft:
			badgeRect = NSMakeRect(0.0, imageSize.height - badgeSize.height, badgeSize.width, badgeSize.height);
			break;
		case WCImageBadgePositionUpperRight:
			badgeRect = NSMakeRect(imageSize.width - badgeSize.width, imageSize.height - badgeSize.height, badgeSize.width, badgeSize.height);
			break;
		case WCImageBadgePositionLowerLeft:
			badgeRect = NSMakeRect(0.0, 0.0, badgeSize.width, badgeSize.height);
			break;
		case WCImageBadgePositionLowerRight:
			badgeRect = NSMakeRect(imageSize.width - badgeSize.width, 0.0, badgeSize.width, badgeSize.height);
			break;
		default:
			break;
	}
	
	[retval lockFocus];
	[self drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil];
	[badgeImage drawInRect:badgeRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	[retval unlockFocus];
	
	return retval;
}
@end
