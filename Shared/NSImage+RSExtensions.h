//
//  NSImage+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 7/22/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

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
