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
	if (![self getResourceValue:&retval forKey:NSURLEffectiveIconKey error:&outError]) {
#ifdef DEBUG
		NSLogObject(outError);
#endif
	}
	return retval;
}
- (NSString *)fileName {
	NSError *outError;
	NSString *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLNameKey error:&outError]) {
#ifdef DEBUG
		NSLogObject(outError);
#endif
	}
	return retval;
}
- (BOOL)isDirectory; {
	NSError *outError;
	NSNumber *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLIsDirectoryKey error:&outError]) {
#ifdef DEBUG
		NSLogObject(outError);
#endif
	}
	return [retval boolValue];
}
- (BOOL)isPackage; {
	NSError *outError;
	NSNumber *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLIsPackageKey error:&outError]) {
#ifdef DEBUG
		NSLogObject(outError);
#endif
	}
	return [retval boolValue];
}
- (NSURL *)parentDirectoryURL; {
	NSError *outError;
	NSURL *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLParentDirectoryURLKey error:&outError]) {
#ifdef DEBUG
		NSLogObject(outError);
#endif
	}
	return retval;
}
- (NSString *)fileUTI; {
	NSError *outError;
	NSString *retval = nil;
	if (![self getResourceValue:&retval forKey:NSURLTypeIdentifierKey error:&outError]) {
#ifdef DEBUG
		NSLogObject(outError);
#endif
	}
	return retval;
}
- (NSString *)filePath; {
	return [self path];
}
@end
