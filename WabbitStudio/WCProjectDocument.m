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
@end

@implementation WCProjectDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_sourceFileDocumentsToFiles release];
	[_filesToSourceFileDocuments release];
	[_UUIDsToFileReferences release];
	[_projectContainer release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	[self setHasUndoManager:NO];
	[self setUndoManager:nil];
	
	return self;
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
	
	NSMapTable *filesToSourceFileDocuments = [NSMapTable mapTableWithWeakToStrongObjects];
	NSMapTable *sourceFileDocumentsToFiles = [NSMapTable mapTableWithWeakToWeakObjects];
	
	for (RSTreeNode *leafNode in [projectContainer descendantLeafNodes]) {
		NSString *UTI = [[leafNode representedObject] fileUTI];
		if ([UTI isEqualToString:WCIncludeFileUTI] ||
			[UTI isEqualToString:WCAssemblyFileUTI] ||
			[UTI isEqualToString:WCActiveServerIncludeFileUTI]) {
			
			NSError *outError;
			WCSourceFileDocument *document = [[[WCSourceFileDocument alloc] initWithContentsOfURL:[[leafNode representedObject] fileURL] ofType:UTI forProjectDocument:self error:&outError] autorelease];
			
			if (document) {
				[filesToSourceFileDocuments setObject:document forKey:[leafNode representedObject]];
				[sourceFileDocumentsToFiles setObject:[leafNode representedObject] forKey:document];
			}
		}
	}
	
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
	WCFileContainer *retval = nil;
	for (WCFileContainer *fileContainer in [[self projectContainer] descendantNodesInclusive]) {
		if ([fileContainer representedObject] == file) {
			retval = fileContainer;
			break;
		}
	}
	return retval;
}

- (IBAction)openQuickly:(id)sender; {
	[[WCOpenQuicklyWindowController sharedWindowController] showOpenQuicklyWindowWithDataSource:self];
}

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
@dynamic fileNamesToFiles;
- (NSDictionary *)fileNamesToFiles {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	for (WCFile *file in [[self sourceFileDocumentsToFiles] objectEnumerator])
		[retval setObject:file forKey:[file fileName]];
	
	return [[retval copy] autorelease];
}

@end
