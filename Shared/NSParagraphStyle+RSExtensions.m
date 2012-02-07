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
+ (NSParagraphStyle *)truncatingHeadParagraphStyle; {
	static NSParagraphStyle *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableParagraphStyle *style = [[[self defaultParagraphStyle] mutableCopy] autorelease];
		[style setLineBreakMode:NSLineBreakByTruncatingHead];
		retval = [style copy];
	});
	return retval;
}
+ (NSParagraphStyle *)truncatingTailParagraphStyle; {
	static NSParagraphStyle *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableParagraphStyle *style = [[[self defaultParagraphStyle] mutableCopy] autorelease];
		[style setLineBreakMode:NSLineBreakByTruncatingTail];
		retval = [style copy];
	});
	return retval;
}
@end
