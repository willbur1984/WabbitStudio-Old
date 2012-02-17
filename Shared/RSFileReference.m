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

static NSString *const RSFileReferenceFileReferenceURLKey = @"fileReferenceURL";
static NSString *const RSFileReferenceFilePathKey = @"filePath";

@interface RSFileReference ()

@end

@implementation RSFileReference
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_kqueue release];
	[_fileURL release];
	[_fileReferenceURL release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"path: %@",[[self fileURL] path]];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	RSFileReference *copy = [[RSFileReference alloc] initWithFileURL:[self fileURL]];
	
	return copy;
}

- (void)watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString *)nm forPath:(NSString *)fpath {
	if ([nm isEqualToString:UKFileWatcherRenameNotification]) {
		if ([[self fileReferenceURL] checkResourceIsReachableAndReturnError:NULL]) {
			[self setFileURL:[[self fileReferenceURL] filePathURL]];
			
			[[self delegate] fileReference:self didMoveToURL:[self fileURL]];
		}
	}
	else if ([nm isEqualToString:UKFileWatcherDeleteNotification]) {
		if ([self ignoreNextFileWatcherNotification]) {
			[self setIgnoreNextFileWatcherNotification:NO];
			return;
		}
		
		[[self delegate] fileReferenceWasDeleted:self];
	}
	else if ([nm isEqualToString:UKFileWatcherWriteNotification]) {
		[[self delegate] fileReferenceWasWrittenTo:self];
	}
}

#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	NSData *bookmarkData = [[self fileReferenceURL] bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark includingResourceValuesForKeys:nil relativeToURL:nil error:NULL];
	if (bookmarkData)
		[retval setObject:bookmarkData forKey:RSFileReferenceFileReferenceURLKey];
	
	[retval setObject:[[self fileURL] path] forKey:RSFileReferenceFilePathKey];
	
	return retval;
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	NSError *outError;
	BOOL bookmarkIsStale = NO;
	NSURL *fileReferenceURL = [NSURL URLByResolvingBookmarkData:[plistRepresentation objectForKey:RSFileReferenceFileReferenceURLKey] options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkIsStale error:&outError];
	
	if (!fileReferenceURL || bookmarkIsStale) {
		NSURL *fileURL = [NSURL fileURLWithPath:[plistRepresentation objectForKey:RSFileReferenceFilePathKey]];
		
		_fileURL = [fileURL copy];
		_fileReferenceURL = [[_fileURL fileReferenceURL] copy];
		
#ifdef DEBUG
		if (outError)
			RSLogObject(outError);
#endif
	}
	else {
		_fileReferenceURL = [fileReferenceURL copy];
		_fileURL = [[_fileReferenceURL filePathURL] copy];
	}
	
	return self;
}

#pragma mark *** Public Methods ***
+ (id)fileReferenceWithFileURL:(NSURL *)fileURL; {
	return [[[[self class] alloc] initWithFileURL:fileURL] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL; {
	if (!(self = [super init]))
		return nil;
	
	_fileURL = [[fileURL filePathURL] copy];
	_fileReferenceURL = [[fileURL fileReferenceURL] copy];
	
	return self;
}

- (void)performCleanup; {
	[NSFileCoordinator removeFilePresenter:self];
}
#pragma mark Properties
@synthesize fileReferenceURL=_fileReferenceURL;
@synthesize fileURL=_fileURL;
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
@dynamic shouldMonitorFile;
- (BOOL)shouldMonitorFile {
	return _fileReferenceFlags.shouldMonitorFile;
}
- (void)setShouldMonitorFile:(BOOL)shouldMonitorFile {
	_fileReferenceFlags.shouldMonitorFile = shouldMonitorFile;
	
	if (shouldMonitorFile) {
		if (_kqueue) {
			[_kqueue removeAllPaths];
			[_kqueue release];
			_kqueue = nil;
		}
		
		if ([[self fileURL] checkResourceIsReachableAndReturnError:NULL]) {
			[_fileReferenceURL release];
			_fileReferenceURL = [[[self fileURL] fileReferenceURL] copy];
			
			_kqueue = [[UKKQueue alloc] init];
			[_kqueue setDelegate:self];
			[_kqueue addPath:[[self fileURL] path] notifyingAbout:UKKQueueNotifyAboutRename|UKKQueueNotifyAboutWrite|UKKQueueNotifyAboutDelete];
		}
	}
}

@end
