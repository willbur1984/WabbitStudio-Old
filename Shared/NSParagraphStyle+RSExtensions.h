//
//  NSParagraphStyle+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 1/9/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSParagraphStyle.h>

@interface NSParagraphStyle (RSExtensions)
+ (NSParagraphStyle *)rightAlignedParagraphStyle;
+ (NSParagraphStyle *)truncatingHeadParagraphStyle;
+ (NSParagraphStyle *)truncatingTailParagraphStyle;
@end
