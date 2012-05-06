//
//  WCFileContainer.m
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
