//
//  WCFileContainer.m
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFileContainer.h"
#import "WCProjectContainer.h"
#import "WCProject.h"
#import "WCProjectDocument.h"
#import "WCSourceFileDocument.h"

@implementation WCFileContainer
#pragma mark *** Subclass Overrides ***

#pragma mark RSPlistArchiving
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super initWithPlistRepresentation:plistRepresentation]))
		return nil;
	
	[[self file] setDelegate:self];
	
	return self;
}

#pragma mark WCFileDelegate
- (NSURL *)locationURLForFile:(WCFile *)file {
	return [[[self parentNode] locationURLForFile:[[self parentNode] representedObject]] URLByAppendingPathComponent:[file fileName]];
}
- (WCSourceFileDocument *)sourceFileDocumentForFile:(WCFile *)file {
	return [[[[self project] document] filesToSourceFileDocuments] objectForKey:file];
}
#pragma mark *** Public Methods ***
+ (id)fileContainerWithFile:(WCFile *)file; {
	return [[(WCFileContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	[file setDelegate:self];
	
	return self;
}
#pragma mark Properties
@dynamic file;
- (WCFile *)file {
	return [self representedObject];
}
@dynamic project;
- (WCProject *)project {
	return [[self parentNode] project];
}
@end
