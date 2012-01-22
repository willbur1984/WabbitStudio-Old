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
#import "UKKQueue.h"

static NSString *const RSFileReferenceUUIDKey = @"UUID";
static NSString *const RSFileReferenceFileReferenceURLKey = @"fileReferenceURL";
static NSString *const RSFileReferenceFilePathKey = @"filePath";

@implementation RSFileReference
- (void)dealloc {
	[_kqueue release];
	[_UUID release];
	[_fileURL release];
	[_fileReferenceURL release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"path: %@",[[self fileURL] path]];
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[self UUID],RSFileReferenceUUIDKey,[[self fileReferenceURL] bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark|NSURLBookmarkCreationPreferFileIDResolution includingResourceValuesForKeys:nil relativeToURL:nil error:NULL],RSFileReferenceFileReferenceURLKey,[[self fileURL] path],RSFileReferenceFilePathKey, nil]];
	
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
		_fileReferenceURL = [[[NSURL fileURLWithPath:[plistRepresentation objectForKey:RSFileReferenceFilePathKey]] fileReferenceURL] copy];
	else
		_fileReferenceURL = [fileReferenceURL retain];
	
#ifdef DEBUG
    NSAssert(_fileReferenceURL, @"fileReferenceURL cannot be nil!");
#endif
	
	_fileURL = [[_fileReferenceURL filePathURL] copy];
	
	_kqueue = [[UKKQueue alloc] init];
	[_kqueue setDelegate:self];
	[_kqueue addPath:[_fileURL path] notifyingAbout:UKKQueueNotifyAboutRename|UKKQueueNotifyAboutDelete|UKKQueueNotifyAboutWrite];
	
	return self;
}

-(void) watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath; {
	if ([nm isEqualToString:UKFileWatcherRenameNotification]) {
		[self setFileURL:[[self fileReferenceURL] filePathURL]];
		[[self delegate] fileReference:self wasMovedToURL:[[self fileReferenceURL] filePathURL]];
	}
	else if ([nm isEqualToString:UKFileWatcherDeleteNotification]) {
		[_kqueue removeAllPaths];
		
		if ([[self fileURL] checkResourceIsReachableAndReturnError:NULL]) {
			[_kqueue addPath:[[self fileURL] path] notifyingAbout:UKKQueueNotifyAboutRename|UKKQueueNotifyAboutDelete|UKKQueueNotifyAboutWrite];
			
			if ([self ignoreNextFileWatcherNotification]) {
				[self setIgnoreNextFileWatcherNotification:NO];
				return;
			}
			
			[[self delegate] fileReferenceWasWrittenTo:self];
		}
		else
			[[self delegate] fileReferenceWasDeleted:self];
	}
	else if ([nm isEqualToString:UKFileWatcherWriteNotification]) {
		[[self delegate] fileReferenceWasWrittenTo:self];
	}
}

+ (RSFileReference *)fileReferenceWithFileURL:(NSURL *)fileURL; {
	return [[[[self class] alloc] initWithFileURL:fileURL] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL; {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[NSString UUIDString] retain];
	_fileURL = [[fileURL filePathURL] copy];
	_fileReferenceURL = [[fileURL fileReferenceURL] copy];
	
	return self;
}

@synthesize UUID=_UUID;
@synthesize fileReferenceURL=_fileReferenceURL;
@dynamic fileURL;
- (NSURL *)fileURL {
	return _fileURL;
}
- (void)setFileURL:(NSURL *)fileURL {
	if (_fileURL == fileURL)
		return;
	
	[_fileURL release];
	_fileURL = [fileURL copy];
}
@dynamic fileIcon;
- (NSImage *)fileIcon {
	NSImage *retval = [[self fileURL] fileIcon];
	if (retval)
		return retval;
	return [NSImage imageNamed:@"FileNotFound"];
}
@dynamic fileName;
- (NSString *)fileName {
	NSString *retval = [[self fileURL] fileName];
	if (retval)
		return retval;
	return [[[self fileURL] path] lastPathComponent];
}
@dynamic fileUTI;
- (NSString *)fileUTI {
	return [[self fileURL] fileUTI];
}
@synthesize delegate=_delegate;
@dynamic ignoreNextFileWatcherNotification;
- (BOOL)ignoreNextFileWatcherNotification {
	return _fileReferenceFlags.ignoreNextFileWatcherNotification;
}
- (void)setIgnoreNextFileWatcherNotification:(BOOL)ignoreNextFileWatcherNotification {
	_fileReferenceFlags.ignoreNextFileWatcherNotification = ignoreNextFileWatcherNotification;
}
@dynamic filePath;
- (NSString *)filePath {
	return [[self fileURL] path];
}
@dynamic parentDirectoryURL;
- (NSURL *)parentDirectoryURL {
	return [[self fileURL] parentDirectoryURL];
}

@end
