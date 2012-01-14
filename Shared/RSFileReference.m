//
//  RSFileReference.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFileReference.h"
#import "NSString+RSExtensions.h"
#import "NSURL+RSExtensions.h"
#import "RSDefines.h"

static NSString *const RSFileReferenceUUIDKey = @"UUID";
static NSString *const RSFileReferenceFileReferenceURLKey = @"fileReferenceURL";
static NSString *const RSFileReferenceFilePathKey = @"filePath";

@implementation RSFileReference
- (void)dealloc {
	[_UUID release];
	[_fileReferenceURL release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"path: %@",[[self fileURL] path]];
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[self UUID],RSFileReferenceUUIDKey,[[self fileReferenceURL] bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark|NSURLBookmarkCreationPreferFileIDResolution includingResourceValuesForKeys:nil relativeToURL:nil error:NULL],RSFileReferenceFileReferenceURLKey,[[self fileReferenceURL] path],RSFileReferenceFilePathKey, nil]];
	
	return retval;
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[plistRepresentation objectForKey:RSFileReferenceUUIDKey] retain];
	
	BOOL bookmarkDataIsStale;
	NSData *bookmarkData = [plistRepresentation objectForKey:RSFileReferenceFileReferenceURLKey];
	NSURL *fileReferenceURL = [[[NSURL alloc] initByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:NULL] autorelease];
	
	if (!fileReferenceURL || bookmarkDataIsStale)
		_fileReferenceURL = [[[NSURL fileURLWithPath:[plistRepresentation objectForKey:RSFileReferenceFilePathKey]] fileReferenceURL] retain];
	else
		_fileReferenceURL = [fileReferenceURL retain];
	
#ifdef DEBUG
    NSAssert(_fileReferenceURL, @"fileReferenceURL cannot be nil!");
#endif
	
	return self;
}

+ (RSFileReference *)fileReferenceWithFileURL:(NSURL *)fileURL; {
	return [[[[self class] alloc] initWithFileURL:fileURL] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL; {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[NSString UUIDString] retain];
	_fileReferenceURL = [[fileURL fileReferenceURL] retain];
	
#ifdef DEBUG
    NSAssert(_fileReferenceURL, @"fileReferenceURL cannot be nil!");
#endif
	
	return self;
}

@synthesize UUID=_UUID;
@synthesize fileReferenceURL=_fileReferenceURL;
@dynamic fileURL;
- (NSURL *)fileURL {
	return [[self fileReferenceURL] filePathURL];
}
- (void)setFileURL:(NSURL *)fileURL {
	[_fileReferenceURL release];
	_fileReferenceURL = [[fileURL fileReferenceURL] retain];
}
@dynamic fileIcon;
- (NSImage *)fileIcon {
	return [[self fileReferenceURL] fileIcon];
}
@dynamic fileName;
- (NSString *)fileName {
	return [[self fileReferenceURL] fileName];
}
@end
