//
//  NSURL+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "NSURL+RSExtensions.h"
#import "RSDefines.h"

@implementation NSURL (RSExtensions)
- (NSImage *)fileIcon; {
	NSError *outError;
	NSImage *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLEffectiveIconKey error:&outError])
		RSLogObject(outError);
	
	return retval;
}
- (NSString *)fileName {
	NSError *outError;
	NSString *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLNameKey error:&outError])
		RSLogObject(outError);
	
	return retval;
}
@end
