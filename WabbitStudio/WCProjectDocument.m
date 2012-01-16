//
//  WCProjectDocument.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectDocument.h"
#import "WCProjectWindowController.h"
#import "WCDocumentController.h"
#import "WCProjectContainer.h"
#import "WCProject.h"
#import "RSDefines.h"

@interface WCProjectDocument ()
@property (readwrite,retain) WCProjectContainer *projectContainer;
@end

@implementation WCProjectDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_projectContainer release];
	[super dealloc];
}

- (void)makeWindowControllers {
	WCProjectWindowController *windowController = [[[WCProjectWindowController alloc] init] autorelease];
	
	[self addWindowController:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];

}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
	if ([typeName isEqualToString:WCProjectFileUTI])
		return YES;
	return NO;
}
- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation {
	if ([typeName isEqualToString:WCProjectFileUTI])
		return YES;
	return NO;
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
	NSDictionary *projectPlist = [[self projectContainer] plistRepresentation];
	
	[self unblockUserInteraction];
	
	NSFileWrapper *projectWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
	NSData *projectData = [NSPropertyListSerialization dataWithPropertyList:projectPlist format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
	if (!projectData)
		return nil;
	
	[projectWrapper addRegularFileWithContents:projectData preferredFilename:WCProjectDataFileName];
	
	return projectWrapper;
}
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	NSFileWrapper *projectDataWrapper = [[fileWrapper fileWrappers] objectForKey:WCProjectDataFileName];
	NSData *projectData = [projectDataWrapper regularFileContents];
	NSPropertyListFormat format;
	NSDictionary *projectDataPlist = [NSPropertyListSerialization propertyListWithData:projectData options:0 format:&format error:outError];
	
	if (!projectDataPlist || format != NSPropertyListXMLFormat_v1_0)
		return NO;
	
	WCProjectContainer *projectContainer = [WCProjectContainer projectContainerWithProject:[WCProject projectWithDocument:self]];
	
	for (NSDictionary *childPlist in [projectDataPlist objectForKey:RSTreeNodeChildNodesKey]) {
		RSTreeNode *childNode = [[NSClassFromString([childPlist objectForKey:RSObjectClassNameKey]) alloc] initWithPlistRepresentation:childPlist];
		
		if (childNode)
			[[projectContainer mutableChildNodes] addObject:childNode];
		
		[childNode release];
	}
	
	if (!projectContainer)
		return NO;
	
	[self setProjectContainer:projectContainer];
	
	return YES;
}

@synthesize projectContainer=_projectContainer;
@dynamic projectWindowController;
- (WCProjectWindowController *)projectWindowController {
	return [[self windowControllers] objectAtIndex:0];
}

@end
