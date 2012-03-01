//
//  WCFile.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFile.h"
#import "RSFileReference.h"
#import "RSDefines.h"
#import "NSImage+RSExtensions.h"
#import "WCSourceFileDocument.h"
#import "WCDocumentController.h"
#import "NSString+RSExtensions.h"
#import "NSURL+RSExtensions.h"

NSString *const WCPasteboardTypeFileUUID = @"org.revsoft.wabbitstudio.uuid";

NSString *const WCFileUUIDKey = @"UUID";

static NSString *const WCFileReferenceKey = @"fileReference";

@implementation WCFile
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	_delegate = nil;
	[_UUID release];
	[_fileReference release];
	[super dealloc];
}

//- (NSString *)description {
//	return [NSString stringWithFormat:@"fileReference: %@",[[self fileReference] description]];
//}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:[self UUID] forKey:WCFileUUIDKey];
	[retval setObject:[[self fileReference] plistRepresentation] forKey:WCFileReferenceKey];
	
	return retval;
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[plistRepresentation objectForKey:WCFileUUIDKey] copy];
	_fileReference = [[RSFileReference alloc] initWithPlistRepresentation:[plistRepresentation objectForKey:WCFileReferenceKey]];
	[_fileReference setDelegate:self];
	[_fileReference setShouldMonitorFile:YES];
	
	return self;
}

#pragma mark QLPreviewItem
- (NSURL *)previewItemURL {
	return [self fileURL];
}
#pragma mark NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
	NSMutableArray *types = [[[[self fileURL] writableTypesForPasteboard:pasteboard] mutableCopy] autorelease];
	
	[types insertObject:WCPasteboardTypeFileUUID atIndex:0];
	
	return types;
}
- (id)pasteboardPropertyListForType:(NSString *)type {	
	if ([type isEqualToString:WCPasteboardTypeFileUUID] || [type isEqualToString:NSPasteboardTypeString]) {
		return [self UUID];
	}
	return [[self fileURL] pasteboardPropertyListForType:type];
}
#pragma mark WCCompletionItem
- (NSString *)completionName {
	return [self fileName];
}
- (NSString *)completionInsertionName {
	return [self fileName];
}
- (NSImage *)completionIcon {
	return [self fileIcon];
}

#pragma mark WCOpenQuicklyItem
- (NSRange)openQuicklyRange {
	return NSEmptyRange;
}
- (NSURL *)openQuicklyFileURL {
	return [self fileURL];
}
- (NSImage *)openQuicklyImage {
	return [self fileIcon];
}
- (NSURL *)openQuicklyLocationURL {
	return [[self delegate] locationURLForFile:self];
}
- (WCSourceFileDocument *)openQuicklySourceFileDocument {
	return [[self delegate] sourceFileDocumentForFile:self];
}
- (NSString *)openQuicklyName {
	return [self fileName];
}
#pragma mark RSFileReferenceDelegate
- (void)fileReference:(RSFileReference *)fileReference didMoveToURL:(NSURL *)url; {
	WCSourceFileDocument *sfDocument = [[self delegate] sourceFileDocumentForFile:self];
	
	if ([[sfDocument fileURL] isEqual:url]) {
		NSDate *currentDate = [[fileReference fileURL] modificationDate];
		
		if (![currentDate isEqualToDate:[sfDocument fileModificationDate]])
			[sfDocument reloadDocumentFromDisk];
	}
	else {
		[self willChangeValueForKey:@"filePath"];
		[self willChangeValueForKey:@"fileName"];
		[sfDocument setFileURL:url];
		[self didChangeValueForKey:@"fileName"];
		[self didChangeValueForKey:@"filePath"];
	}
}
- (void)fileReferenceWasDeleted:(RSFileReference *)fileReference {
	[self willChangeValueForKey:@"fileIcon"];
	
	[self didChangeValueForKey:@"fileIcon"];
}
- (void)fileReferenceWasWrittenTo:(RSFileReference *)fileReference; {
	if ([self isSourceFile]) {
		WCSourceFileDocument *sfDocument = [[self delegate] sourceFileDocumentForFile:self];
		NSDate *currentDate = [[fileReference fileURL] modificationDate];
		
		if (![currentDate isEqualToDate:[sfDocument fileModificationDate]])
			[sfDocument reloadDocumentFromDisk];
	}
}
#pragma mark *** Public Methods ***
+ (id)fileWithFileURL:(NSURL *)fileURL; {
	return [[[[self class] alloc] initWithFileURL:fileURL] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL; {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[NSString UUIDString] copy];
	_fileReference = [[RSFileReference alloc] initWithFileURL:fileURL];
	[_fileReference setDelegate:self];
	[_fileReference setShouldMonitorFile:YES];
	
	return self;
}
#pragma mark Properties
@synthesize delegate=_delegate;
@synthesize fileReference=_fileReference;
@dynamic fileName;
- (NSString *)fileName {
	return [[self fileReference] fileName];
}
- (void)setFileName:(NSString *)fileName {
	
}
@dynamic fileIcon;
- (NSImage *)fileIcon {
	if ([self isEdited])
		return [[[self fileReference] fileIcon] unsavedImageFromImage];
	return [[self fileReference] fileIcon];
}
+ (NSSet *)keyPathsForValuesAffectingFileIcon {
	return [NSSet setWithObjects:@"edited", nil];
}
@dynamic fileURL;
- (NSURL *)fileURL {
	return [[self fileReference] fileURL];
}
@dynamic fileUTI;
- (NSString *)fileUTI {
	return [[self fileReference] fileUTI];
}
@dynamic edited;
- (BOOL)isEdited {
	return _fileFlags.edited;
}
- (void)setEdited:(BOOL)edited {
	_fileFlags.edited = edited;
}
@dynamic filePath;
- (NSString *)filePath {
	return [[self fileReference] filePath];
}
@dynamic sourceFile;
- (BOOL)isSourceFile {
	return [[[WCDocumentController sharedDocumentController] sourceFileDocumentUTIs] containsObject:[self fileUTI]];
}
@dynamic parentDirectoryURL;
- (NSURL *)parentDirectoryURL {
	return [[self fileReference] parentDirectoryURL];
}
@synthesize UUID=_UUID;
@dynamic errors;
- (BOOL)hasErrors {
	return _fileFlags.errors;
}
- (void)setErrors:(BOOL)errors {
	_fileFlags.errors = errors;
}
@dynamic warnings;
- (BOOL)hasWarnings {
	return _fileFlags.warnings;
}
- (void)setWarnings:(BOOL)warnings {
	_fileFlags.warnings = warnings;
}
@dynamic issueIcon;
- (NSImage *)issueIcon {
	if ([self hasErrors])
		return [[self fileIcon] badgedImageWithImage:[NSImage imageNamed:@"Error"] badgePosition:WCImageBadgePositionLowerRight];
	else if ([self hasWarnings])
		return [[self fileIcon] badgedImageWithImage:[NSImage imageNamed:@"Warning"] badgePosition:WCImageBadgePositionLowerRight];
	return [self fileIcon];
}
+ (NSSet *)keyPathsForValuesAffectingIssueIcon {
	return [NSSet setWithObjects:@"edited",@"errors",@"warnings", nil];
}

@end
