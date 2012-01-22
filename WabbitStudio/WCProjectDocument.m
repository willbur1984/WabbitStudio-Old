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
#import "WCSourceFileDocument.h"
#import "WCTabViewController.h"
#import "WCOpenQuicklyWindowController.h"
#import "WCFileContainer.h"
#import "WCSourceScanner.h"
#import "WCProjectNavigatorViewController.h"
#import <PSMTabBarControl/PSMTabBarControl.h>

NSString *const WCProjectDocumentFileReferencesKey = @"fileReferences";
NSString *const WCProjectDocumentProjectContainerKey = @"projectContainer";

NSString *const WCProjectDataFileName = @"project.plist";

@interface WCProjectDocument ()
@property (readwrite,retain) WCProjectContainer *projectContainer;
@property (readwrite,retain) NSMapTable *filesToSourceFileDocuments;
@property (readwrite,retain) NSMapTable *sourceFileDocumentsToFiles;
@property (readwrite,retain) NSMapTable *filesToFileContainers;
@end

@implementation WCProjectDocument
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_openFiles release];
	[_unsavedFiles release];
	[_filesToFileContainers release];
	[_sourceFileDocumentsToFiles release];
	[_filesToSourceFileDocuments release];
	[_projectContainer release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	[self setHasUndoManager:NO];
	[self setUndoManager:nil];
	
	_unsavedFiles = [[NSHashTable hashTableWithWeakObjects] retain];
	_openFiles = [[NSCountedSet alloc] initWithCapacity:0];
	
	return self;
}

- (void)makeWindowControllers {
	WCProjectWindowController *windowController = [[[WCProjectWindowController alloc] init] autorelease];
	
	[self addWindowController:windowController];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidAddNewGroup:) name:WCProjectNavigatorDidAddNewGroupNotification object:[windowController projectNavigatorViewController]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidRemoveNodes:) name:WCProjectNavigatorDidRemoveNodesNotification object:[windowController projectNavigatorViewController]];
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
    return YES;
}

+ (BOOL)preservesVersions {
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
	
	NSMapTable *filesToFileContainers = [NSMapTable mapTableWithWeakToWeakObjects];
	NSMapTable *filesToSourceFileDocuments = [NSMapTable mapTableWithWeakToStrongObjects];
	NSMapTable *sourceFileDocumentsToFiles = [NSMapTable mapTableWithWeakToWeakObjects];
	
	for (WCFileContainer *fileContainer in [projectContainer descendantNodesInclusive]) {
		[filesToFileContainers setObject:fileContainer forKey:[fileContainer representedObject]];
		
		if ([fileContainer isLeafNode] &&
			[[fileContainer representedObject] isSourceFile]) {
			
			NSError *outError;
			WCSourceFileDocument *document = [[[WCSourceFileDocument alloc] initWithContentsOfURL:[[fileContainer representedObject] fileURL] ofType:[[fileContainer representedObject] fileUTI] error:&outError] autorelease];
			[document setProjectDocument:self];
			
			if (document) {
				[filesToSourceFileDocuments setObject:document forKey:[fileContainer representedObject]];
				[sourceFileDocumentsToFiles setObject:[fileContainer representedObject] forKey:document];
			}
		}
	}
	
	[self setFilesToFileContainers:filesToFileContainers];
	[self setFilesToSourceFileDocuments:filesToSourceFileDocuments];
	[self setSourceFileDocumentsToFiles:sourceFileDocumentsToFiles];
	
	return YES;
}

- (IBAction)saveDocument:(id)sender {
	[super saveDocument:nil];
	
	NSTabViewItem *selectedTabViewItem = [[[[[self projectWindowController] tabViewController] tabBarControl] tabView] selectedTabViewItem];
	if (selectedTabViewItem)
		[[selectedTabViewItem identifier] saveDocument:nil];
}
#pragma mark WCOpenQuicklyDataSource
- (NSArray *)openQuicklyItems {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	for (WCFileContainer *fContainer in [[self projectContainer] descendantLeafNodes]) {
		[retval addObject:[fContainer representedObject]];
		
		WCSourceFileDocument *sfDocument = [[self filesToSourceFileDocuments] objectForKey:[fContainer representedObject]];
		
		if (sfDocument)
			[retval addObjectsFromArray:[[sfDocument sourceScanner] symbols]];
	}
	
	return [[retval copy] autorelease];
}
- (NSString *)openQuicklyProjectName {
	return [self displayName];
}
#pragma mark *** Public Methods ***
- (WCSourceTextViewController *)openTabForFile:(WCFile *)file; {
	WCSourceFileDocument *sfDocument = [[self filesToSourceFileDocuments] objectForKey:file];
	if (sfDocument)
		return [self openTabForSourceFileDocument:sfDocument];
	else {
		WCFileContainer *fileContainer = [self fileContainerForFile:file];
		
		[[[self projectWindowController] projectNavigatorViewController] setSelectedObjects:[NSArray arrayWithObjects:fileContainer, nil]];
	}
	return nil;
}
- (WCSourceTextViewController *)openTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	return [[[self projectWindowController] tabViewController] addTabForSourceFileDocument:sourceFileDocument];
}

- (WCFileContainer *)fileContainerForFile:(WCFile *)file; {
	return [[self filesToFileContainers] objectForKey:file];
}
#pragma mark IBActions
- (IBAction)openQuickly:(id)sender; {
	[[WCOpenQuicklyWindowController sharedWindowController] showOpenQuicklyWindowWithDataSource:self];
}
#pragma mark Properties
@synthesize projectContainer=_projectContainer;
@dynamic projectWindowController;
- (WCProjectWindowController *)projectWindowController {
	return [[self windowControllers] objectAtIndex:0];
}
@synthesize filesToSourceFileDocuments=_filesToSourceFileDocuments;
@dynamic sourceFileDocuments;
- (NSArray *)sourceFileDocuments {
	return [[[self filesToSourceFileDocuments] objectEnumerator] allObjects];
}
@synthesize sourceFileDocumentsToFiles=_sourceFileDocumentsToFiles;
@dynamic filePathsToFiles;
- (NSDictionary *)filePathsToFiles {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	for (WCFile *file in [[self sourceFileDocumentsToFiles] objectEnumerator])
		[retval setObject:file forKey:[file filePath]];
	
	return [[retval copy] autorelease];
}
@synthesize unsavedFiles=_unsavedFiles;
@synthesize filesToFileContainers=_filesToFileContainers;
@synthesize openFiles=_openFiles;
#pragma mark *** Private Methods ***

#pragma mark Notifications
- (void)_projectNavigatorDidAddNewGroup:(NSNotification *)note {
	WCGroupContainer *newGroupContainer = [[note userInfo] objectForKey:WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey];
	
	[[self filesToFileContainers] setObject:newGroupContainer forKey:[newGroupContainer representedObject]];
}
- (void)_projectNavigatorDidRemoveNodes:(NSNotification *)note {
	NSSet *removedFileContainers = [[note userInfo] objectForKey:WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey];
	
	for (WCFileContainer *fileContainer in removedFileContainers)
		[[self filesToFileContainers] removeObjectForKey:[fileContainer representedObject]];
}

@end
