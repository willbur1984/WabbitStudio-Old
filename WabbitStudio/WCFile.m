//
//  WCFile.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFile.h"
#import "RSFileReference.h"

static NSString *const WCFileReferenceKey = @"fileReference";

@implementation WCFile
- (void)dealloc {
	[_fileReference release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"fileReference: %@",[self fileReference]];
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:[[self fileReference] plistRepresentation] forKey:WCFileReferenceKey];
	
	return retval;
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_fileReference = [[RSFileReference alloc] initWithPlistRepresentation:[plistRepresentation objectForKey:WCFileReferenceKey]];
	
	return self;
}

#pragma mark QLPreviewItem
- (NSURL *)previewItemURL {
	return [self fileURL];
}

+ (id)fileWithFileURL:(NSURL *)fileURL; {
	return [[[[self class] alloc] initWithFileURL:fileURL] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL; {
	if (!(self = [super init]))
		return nil;
	
	_fileReference = [[RSFileReference alloc] initWithFileURL:fileURL];
	
	return self;
}

@synthesize fileReference=_fileReference;
@dynamic fileName;
- (NSString *)fileName {
	return [[self fileReference] fileName];
}
@dynamic fileIcon;
- (NSImage *)fileIcon {
	return [[self fileReference] fileIcon];
}
@dynamic fileURL;
- (NSURL *)fileURL {
	return [[self fileReference] fileURL];
}

@end
