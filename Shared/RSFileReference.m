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

static NSString *const RSFileReferenceFileReferenceURLKey = @"fileReferenceURL";
static NSString *const RSFileReferenceFilePathKey = @"filePath";

@interface RSFileReference ()
@property (readonly) NSOperationQueue *operationQueue;
@end

@implementation RSFileReference
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_operationQueue release];
	[_fileURLLock release];
	[_fileURL release];
	[_fileReferenceURL release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"path: %@",[[self fileURL] path]];
}
#pragma mark NSFilePresenter
- (NSURL *)presentedItemURL {
	return [self fileURL];
}
- (NSOperationQueue *)presentedItemOperationQueue {
	return [self operationQueue];
}
- (void)relinquishPresentedItemToWriter:(void (^)(void (^)(void)))writer {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	writer(^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self delegate] fileReferenceWasWrittenTo:self];
		});
	});
}
- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self delegate] fileReferenceWasDeleted:self];
	});
	completionHandler(nil);
}
- (void)presentedItemDidMoveToURL:(NSURL *)newURL {	
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	
	[self setFileURL:newURL];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_fileReferenceURL release];
		_fileReferenceURL = [[newURL fileReferenceURL] copy];
		
		[[self delegate] fileReference:self wasMovedToURL:newURL];
	});
}
- (void)presentedItemDidChange {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self delegate] fileReferenceWasWrittenTo:self];
	});
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
		if (outError)
			RSLog(@"%@",outError);
		
		NSURL *fileURL = [NSURL fileURLWithPath:[plistRepresentation objectForKey:RSFileReferenceFilePathKey]];
		
		_fileURL = [fileURL copy];
		_fileReferenceURL = [[_fileURL fileReferenceURL] copy];
	}
	else {
		_fileReferenceURL = [fileReferenceURL copy];
		_fileURL = [[_fileReferenceURL filePathURL] copy];
	}
	
	_fileURLLock = [[NSLock alloc] init];
	
	_operationQueue = [[NSOperationQueue alloc] init];
	[_operationQueue setMaxConcurrentOperationCount:1];
	
	[NSFileCoordinator addFilePresenter:self];
	
	return self;
}

#pragma mark *** Public Methods ***
+ (id)fileReferenceWithFileURL:(NSURL *)fileURL; {
	return [[[[self class] alloc] initWithFileURL:fileURL] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL; {
	if (!(self = [super init]))
		return nil;
	
	_fileURLLock = [[NSLock alloc] init];
	_fileURL = [[fileURL filePathURL] copy];
	_fileReferenceURL = [[fileURL fileReferenceURL] copy];
	
	return self;
}

- (void)performCleanup; {
	[NSFileCoordinator removeFilePresenter:self];
}
#pragma mark Properties
@synthesize fileReferenceURL=_fileReferenceURL;
@dynamic fileURL;
- (NSURL *)fileURL {
	NSURL *retval;
	
	[_fileURLLock lock];
	retval = [[_fileURL copy] autorelease];
	[_fileURLLock unlock];
	
	return retval;
}
- (void)setFileURL:(NSURL *)fileURL {
	[_fileURLLock lock];
	[_fileURL release];
	_fileURL = [fileURL copy];
	[_fileURLLock unlock];
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
@dynamic shouldMonitorFile;
- (BOOL)shouldMonitorFile {
	return _fileReferenceFlags.shouldMonitorFile;
}
- (void)setShouldMonitorFile:(BOOL)shouldMonitorFile {
	_fileReferenceFlags.shouldMonitorFile = shouldMonitorFile;
	
}
@synthesize operationQueue=_operationQueue;

@end
