//
//  NSImage+RSExtensions.h
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

#import <AppKit/NSImage.h>

typedef enum _WCImageBadgePosition {
	WCImageBadgePositionUpperLeft,
	WCImageBadgePositionUpperRight,
	WCImageBadgePositionLowerLeft,
	WCImageBadgePositionLowerRight
	
} WCImageBadgePosition;

@interface NSImage (NSImage_RSExtensions)
- (NSImage *)unsavedImageFromImage;
- (NSImage *)darkenedImageWithBrightnessReduction:(CGFloat)brightness;

- (NSImage *)badgedImageWithImage:(NSImage *)badgeImage badgePosition:(WCImageBadgePosition)badgePosition;
- (NSImage *)badgedImageOfSize:(NSSize)imageSize badgeImage:(NSImage *)badgeImage badgeSize:(NSSize)badgeSize badgePosition:(WCImageBadgePosition)badgePosition;
@end
