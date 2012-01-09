//
//  NSParagraphStyle+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/9/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "NSParagraphStyle+RSExtensions.h"

@implementation NSParagraphStyle (RSExtensions)
+ (NSParagraphStyle *)rightAlignedParagraphStyle; {
	static NSParagraphStyle *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableParagraphStyle *style = [[[self defaultParagraphStyle] mutableCopy] autorelease];
		[style setAlignment:NSRightTextAlignment];
		retval = [style copy];
	});
	return retval;
}
@end
