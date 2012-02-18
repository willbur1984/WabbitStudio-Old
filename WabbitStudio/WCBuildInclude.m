//
//  WCBuildInclude.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildInclude.h"
#import "RSFileReference.h"

static NSString *const WCBuildIncludeFileReferenceKey = @"fileReference";

@implementation WCBuildInclude
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_fileReference release];
	[super dealloc];
}
#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard; {
	return [NSArray arrayWithObjects:(NSString *)kUTTypeFileURL,nil];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
	if ([type isEqualToString:(NSString *)kUTTypeFileURL])
		return NSPasteboardReadingAsPropertyList;
	return NSPasteboardReadingAsData;
}
- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
	[self release];
	self = nil;
	if ([type isEqualToString:(NSString *)kUTTypeFileURL]) {
		self = [[WCBuildInclude alloc] initWithDirectoryURL:[NSURL URLWithString:propertyList]];
	}
	return self;
}

#pragma mark RSFileReferenceDelegate
- (void)fileReference:(RSFileReference *)fileReference didMoveToURL:(NSURL *)url {
	[self willChangeValueForKey:@"name"];
	[self willChangeValueForKey:@"path"];
	[self didChangeValueForKey:@"name"];
	[self didChangeValueForKey:@"path"];
}
- (void)fileReferenceWasDeleted:(RSFileReference *)fileReference {
	
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:[[self fileReference] plistRepresentation] forKey:WCBuildIncludeFileReferenceKey];
	
	return [[retval copy] autorelease];
}

- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_fileReference = [[RSFileReference alloc] initWithPlistRepresentation:[plistRepresentation objectForKey:WCBuildIncludeFileReferenceKey]];
	
	return self;
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCBuildInclude *copy = [[WCBuildInclude alloc] init];
	
	copy->_fileReference = [_fileReference retain];
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCBuildInclude *copy = [[WCBuildInclude alloc] init];
	
	copy->_fileReference = [_fileReference copy];
	
	return copy;
}
#pragma mark *** Public Methods ***
+ (id)buildIncludeWithDirectoryURL:(NSURL *)directoryURL; {
	return [[[[self class] alloc] initWithDirectoryURL:directoryURL] autorelease];
}
- (id)initWithDirectoryURL:(NSURL *)directoryURL; {
	if (!(self = [super init]))
		return nil;
	
	_fileReference = [[RSFileReference alloc] initWithFileURL:directoryURL];
	
	return self;
}
#pragma mark Properties
@dynamic name;
- (NSString *)name {
	return [[self fileReference] fileName];
}
@dynamic path;
- (NSString *)path {
	return [[self fileReference] filePath];
}
@dynamic icon;
- (NSImage *)icon {
	return [NSImage imageNamed:NSImageNameFolder];
}
@synthesize fileReference=_fileReference;

@end
