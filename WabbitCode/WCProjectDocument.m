//
//  WCProjectDocument.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
#import "GTMNSData+zlib.h"
#import "WCSourceFileSeparateWindowController.h"
#import "NSWindow+ULIZoomEffect.h"
#import "RSNavigatorControl.h"
#import "NSTreeController+RSExtensions.h"
#import "RSFileReference.h"
#import "NDTrie.h"
#import "WCBuildTarget.h"
#import "WCManageBuildTargetsWindowController.h"
#import "WCBuildController.h"
#import "WCEditBuildTargetWindowController.h"
#import "WCSearchNavigatorViewController.h"
#import "WCBuildInclude.h"
#import "WCBreakpointManager.h"
#import "WCFileBreakpoint.h"
#import "WCDebugController.h"
#import "WCCalculatorWindowController.h"

#import <PSMTabBarControl/PSMTabBarControl.h>

NSString *const WCProjectDocumentFileReferencesKey = @"fileReferences";
NSString *const WCProjectDocumentProjectContainerKey = @"projectContainer";
NSString *const WCProjectDocumentBuildTargetsKey = @"buildTargets";
NSString *const WCProjectDocumentFileBreakpointsKey = @"fileBreakpoints";

NSString *const WCProjectDataFileName = @"project.wstudioprojdata";
NSString *const WCProjectSettingsFileExtension = @"plist";

@interface WCProjectDocument ()
@property (readwrite,retain) WCProjectContainer *projectContainer;
@property (readwrite,retain) NSMapTable *filesToSourceFileDocuments;
@property (readwrite,retain) NSMapTable *sourceFileDocumentsToFiles;
@property (readwrite,retain) NSMapTable *filesToFileContainers;
@property (readwrite,retain) NSMutableDictionary *UUIDsToFiles;
@property (readwrite,copy) NSDictionary *projectSettings;
@property (readwrite,retain) NSHashTable *projectSettingsProviders;
@property (readwrite,retain) NDTrie *fileCompletions;
@property (readwrite,retain) NSArray *buildTargets;

- (WCSourceFileSeparateWindowController *)_sourceFileSeparateWindowControllerForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
@end

@implementation WCProjectDocument
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_debugController release];
	[_breakpointManager release];
	[_buildController release];
	[_buildTargets release];
	[_fileCompletions release];
	[_openFiles release];
	[_unsavedFiles release];
	[_projectSettingsProviders release];
	[_projectSettings release];
	[_UUIDsToFiles release];
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
	_projectSettingsProviders = [[NSHashTable hashTableWithWeakObjects] retain];
	_buildTargets = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}

- (void)makeWindowControllers {
	WCProjectWindowController *windowController = [[[WCProjectWindowController alloc] init] autorelease];
	
	[windowController setShouldCloseDocument:YES];
	
	[self addWindowController:windowController];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidAddNewGroup:) name:WCProjectNavigatorDidAddNewGroupNotification object:[windowController projectNavigatorViewController]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidAddNodes:) name:WCProjectNavigatorDidAddNodesNotification object:[windowController projectNavigatorViewController]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_projectNavigatorDidRemoveNodes:) name:WCProjectNavigatorDidRemoveNodesNotification object:[windowController projectNavigatorViewController]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowWillClose:) name:NSWindowWillCloseNotification object:[windowController window]];
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
	NSMutableDictionary *projectPlist = [[[[self projectContainer] plistRepresentation] mutableCopy] autorelease];
	
	[projectPlist setObject:[[self buildTargets] valueForKey:RSPlistArchivingPlistRepresentationKey] forKey:WCProjectDocumentBuildTargetsKey];
	[projectPlist setObject:[[[self breakpointManager] allFileBreakpoints] valueForKey:RSPlistArchivingPlistRepresentationKey] forKey:WCProjectDocumentFileBreakpointsKey];
	
	NSMutableDictionary *projectSettings = [NSMutableDictionary dictionaryWithDictionary:[self projectSettings]];
	
	for (id <WCProjectDocumentSettingsProvider> settingsProvider in [self projectSettingsProviders])
		[projectSettings setObject:[settingsProvider projectDocumentSettings] forKey:[settingsProvider projectDocumentSettingsKey]];
	
	[self unblockUserInteraction];
	
	NSFileWrapper *projectWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
	NSData *projectData = [NSPropertyListSerialization dataWithPropertyList:projectPlist format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
	if (!projectData)
		return nil;
	
#ifndef DEBUG
	projectData = [NSData gtm_dataByGzippingData:projectData];
#endif
	
	[projectWrapper addRegularFileWithContents:projectData preferredFilename:WCProjectDataFileName];
	
	NSData *settingsData = [NSPropertyListSerialization dataWithPropertyList:projectSettings format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
	
	[projectWrapper addRegularFileWithContents:settingsData preferredFilename:[NSUserName() stringByAppendingPathExtension:WCProjectSettingsFileExtension]];
	
	return projectWrapper;
}
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	NSFileWrapper *projectDataWrapper = [[fileWrapper fileWrappers] objectForKey:WCProjectDataFileName];
	NSData *projectData = [projectDataWrapper regularFileContents];
	
#ifndef DEBUG
	projectData = [NSData gtm_dataByInflatingData:projectData];
#endif
	
	NSPropertyListFormat format;
	NSDictionary *projectDataPlist = [NSPropertyListSerialization propertyListWithData:projectData options:0 format:&format error:outError];
	
	if (!projectDataPlist || format != NSPropertyListXMLFormat_v1_0)
		return NO;
	
	WCProjectContainer *projectContainer = [WCProjectContainer projectContainerWithProject:[WCProject projectWithDocument:self]];
	
	for (NSDictionary *childPlist in [projectDataPlist objectForKey:RSTreeNodeChildNodesKey]) {
		RSTreeNode *childNode = [[[NSClassFromString([childPlist objectForKey:RSObjectClassNameKey]) alloc] initWithPlistRepresentation:childPlist] autorelease];
		
		if (childNode)
			[[projectContainer mutableChildNodes] addObject:childNode];
	}
	
	if (!projectContainer)
		return NO;
	
	[self setProjectContainer:projectContainer];
	
	NSMapTable *filesToFileContainers = [NSMapTable mapTableWithWeakToWeakObjects];
	NSMapTable *filesToSourceFileDocuments = [NSMapTable mapTableWithWeakToStrongObjects];
	NSMapTable *sourceFileDocumentsToFiles = [NSMapTable mapTableWithWeakToWeakObjects];
	NSMutableDictionary *UUIDsToFiles = [NSMutableDictionary dictionaryWithCapacity:0];
	NDMutableTrie *fileCompletions = [NDMutableTrie trie];
	
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
		
		if ([fileContainer isLeafNode])
			[fileCompletions setObject:[fileContainer representedObject] forKey:[[[fileContainer representedObject] fileName] lowercaseString]];
			
		[UUIDsToFiles setObject:[fileContainer representedObject] forKey:[[fileContainer representedObject] UUID]];
	}
	
	[self setFilesToFileContainers:filesToFileContainers];
	[self setFilesToSourceFileDocuments:filesToSourceFileDocuments];
	[self setSourceFileDocumentsToFiles:sourceFileDocumentsToFiles];
	[self setUUIDsToFiles:UUIDsToFiles];
	[self setFileCompletions:fileCompletions];
	
	NSMutableArray *buildTargets = [NSMutableArray arrayWithCapacity:0];
	
	for (NSDictionary *buildTargetPlist in [projectDataPlist objectForKey:WCProjectDocumentBuildTargetsKey]) {
		WCBuildTarget *buildTarget = [[[WCBuildTarget alloc] initWithPlistRepresentation:buildTargetPlist] autorelease];
		
		if (buildTarget) {
			[buildTargets addObject:buildTarget];
			[buildTarget setProjectDocument:self];
		}
	}
	
	[self setBuildTargets:buildTargets];
	
	for (NSDictionary *fileBreakpointPlist in [projectDataPlist objectForKey:WCProjectDocumentFileBreakpointsKey]) {
		WCFileBreakpoint *fileBreakpoint = [[[WCFileBreakpoint alloc] initWithPlistRepresentation:fileBreakpointPlist] autorelease];
		
		if (fileBreakpoint) {
			[fileBreakpoint setProjectDocument:self];
			
			[[self breakpointManager] addFileBreakpoint:fileBreakpoint];
		}
	}
	
	// WCProject needs to start observing our build targets and their properties, but it needs to happen on the main thread
	dispatch_async(dispatch_get_main_queue(), ^{
		[[projectContainer representedObject] performSetup];
	});
	
	NSFileWrapper *settingsDataWrapper = [[fileWrapper fileWrappers] objectForKey:[NSUserName() stringByAppendingPathExtension:WCProjectSettingsFileExtension]];
	if (!settingsDataWrapper)
		return YES;
	
	NSData *settingsData = [settingsDataWrapper regularFileContents];
	NSDictionary *settingsPlist = [NSPropertyListSerialization propertyListWithData:settingsData options:NSPropertyListImmutable format:&format error:outError];
	
	[self setProjectSettings:settingsPlist];
	
	return YES;
}

- (IBAction)saveDocument:(id)sender {
	[super saveDocument:nil];
	
	NSTabViewItem *selectedTabViewItem = [[[[[self currentTabViewContext] tabViewController] tabBarControl] tabView] selectedTabViewItem];
	if (selectedTabViewItem && [[selectedTabViewItem identifier] isDocumentEdited])
		[[selectedTabViewItem identifier] saveDocument:nil];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(editActiveBuildTarget:)) {
		WCBuildTarget *buildTarget = [self activeBuildTarget];
		
		if (buildTarget)
			[menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Edit Active Build Target \"%@\"\u2026", @"Edit Active Build Target menu item title format string"),[buildTarget name]]];
		else {
			[menuItem setTitle:NSLocalizedString(@"Edit Active Build Target\u2026", @"Edit Active Build Target with ellipsis")];
			return NO;
		}
	}
	else if ([menuItem action] == @selector(toggleBreakpoints:)) {
		if ([[self breakpointManager] breakpointsEnabled])
			[menuItem setTitle:NSLocalizedString(@"Disable Breakpoints", @"Disable Breakpoints")];
		else
			[menuItem setTitle:NSLocalizedString(@"Enable Breakpoints", @"Enable Breakpoints")];
	}
	else if ([menuItem action] == @selector(toggleIssues:)) {
		if ([[self buildController] issuesEnabled])
			[menuItem setTitle:NSLocalizedString(@"Hide All Issues", @"Hide All Issues")];
		else
			[menuItem setTitle:NSLocalizedString(@"Show All Issues", @"Show All Issues")];
	}
	return [super validateMenuItem:menuItem];
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
- (WCProjectDocument *)openQuicklyProjectDocument {
	return self;
}
#pragma mark *** Public Methods ***

- (WCSourceTextViewController *)openTabForFile:(WCFile *)file tabViewContext:(id<WCTabViewContext>)tabViewContext; {
	WCSourceFileDocument *sfDocument = [[self filesToSourceFileDocuments] objectForKey:file];
	if (sfDocument)
		return [self openTabForSourceFileDocument:sfDocument tabViewContext:tabViewContext];
	else
		[[[self projectWindowController] projectNavigatorViewController] setSelectedModelObjects:[NSArray arrayWithObjects:file, nil]];
	return nil;
}
- (WCSourceTextViewController *)openTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument tabViewContext:(id<WCTabViewContext>)tabViewContext {
	if (!tabViewContext)
		tabViewContext = [self currentTabViewContext];
	return [[tabViewContext tabViewController] addTabForSourceFileDocument:sourceFileDocument];
}
- (id<WCTabViewContext>)currentTabViewContext; {
	id windowController = [[[NSApplication sharedApplication] keyWindow] windowController];
	if ([windowController conformsToProtocol:@protocol(WCTabViewContext)])
		return windowController;
	return [self projectWindowController];
}

- (WCSourceFileSeparateWindowController *)openSeparateEditorForFile:(WCFile *)file; {
	WCSourceFileDocument *sfDocument = [[self filesToSourceFileDocuments] objectForKey:file];
	
	return [self openSeparateEditorForSourceFileDocument:sfDocument];
}
- (WCSourceFileSeparateWindowController *)openSeparateEditorForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	WCSourceFileSeparateWindowController *windowController = [self createSeparateEditorForSourceFileDocument:sourceFileDocument];
	
	if (windowController) {
		[windowController showWindow:nil];
	}
	else {
		windowController = [[[WCSourceFileSeparateWindowController alloc] initWithSourceFileDocument:sourceFileDocument] autorelease];
		[self addWindowController:windowController];
		
		if ([[[[self projectWindowController] navigatorControl] selectedItemIdentifier] isEqualToString:@"project"]) {
			NSArray *files = [NSArray arrayWithObjects:[[self sourceFileDocumentsToFiles] objectForKey:sourceFileDocument], nil];
			NSTreeNode *item = [[[[[self projectWindowController] projectNavigatorViewController] treeController] treeNodesForModelObjects:files] lastObject];
			NSInteger itemRow = [[[[self projectWindowController] projectNavigatorViewController] outlineView] rowForItem:item];
			NSTableCellView *view = [[[[self projectWindowController] projectNavigatorViewController] outlineView] viewAtColumn:0 row:itemRow makeIfNecessary:NO];
			if (view) {
				NSRect zoomRect = [[view window] convertRectToScreen:[view convertRectToBase:[[view imageView] bounds]]];
				
				[[windowController window] makeKeyAndOrderFrontWithZoomEffectFromRect:zoomRect];
			}
			else
				[[windowController window] makeKeyAndOrderFrontWithPopEffect];
		}
		else
			[[windowController window] makeKeyAndOrderFrontWithPopEffect];
	}
	
	return windowController;
}

- (WCSourceFileSeparateWindowController *)createSeparateEditorForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	return [self _sourceFileSeparateWindowControllerForSourceFileDocument:sourceFileDocument];
}

- (WCFileContainer *)fileContainerForFile:(WCFile *)file; {
	return [[self filesToFileContainers] objectForKey:file];
}
#pragma mark IBActions
- (IBAction)openQuickly:(id)sender; {
	[[WCOpenQuicklyWindowController sharedWindowController] showOpenQuicklyWindowWithDataSource:self];
}

- (IBAction)build:(id)sender; {
	[[self buildController] build];
}
- (IBAction)buildAndRun:(id)sender; {
	[[self buildController] buildAndRun];
}

- (IBAction)editActiveBuildTarget:(id)sender; {
	WCEditBuildTargetWindowController *windowController = [WCEditBuildTargetWindowController editBuildTargetWindowControllerWithBuildTarget:[self activeBuildTarget]];
	
	[windowController showEditBuildTargetWindow];
}
- (IBAction)manageBuildTargets:(id)sender; {
	WCManageBuildTargetsWindowController *windowController = [WCManageBuildTargetsWindowController manageBuildTargetsWindowControllerWithProjectDocument:self];
	
	[windowController showManageBuildTargetsWindow];
}

- (IBAction)findInProject:(id)sender; {
	[[[self projectWindowController] navigatorControl] setSelectedItemIdentifier:@"search"];
	[[[self projectWindowController] window] makeFirstResponder:[[[self projectWindowController] searchNavigatorViewController] searchField]];
}

- (IBAction)toggleBreakpoints:(id)sender; {
	[[self breakpointManager] setBreakpointsEnabled:(![[self breakpointManager] breakpointsEnabled])];
}
- (IBAction)toggleIssues:(id)sender; {
	[[self buildController] setIssuesEnabled:(![[self buildController] issuesEnabled])];
}

- (IBAction)changeRomOrSavestateForRunning:(id)sender; {
	[[self debugController] changeRomOrSavestateForRunning];
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
@dynamic filePaths;
- (NSSet *)filePaths {
	NSArray *files = [[[self UUIDsToFiles] objectEnumerator] allObjects];
	NSMutableSet *retval = [NSMutableSet setWithCapacity:[files count]];
	
	for (WCFile *file in files)
		[retval addObject:[file filePath]];
	
	return [[retval copy] autorelease];
}
@synthesize unsavedFiles=_unsavedFiles;
@synthesize filesToFileContainers=_filesToFileContainers;
@synthesize openFiles=_openFiles;
@dynamic openSourceFileDocuments;
- (NSArray *)openSourceFileDocuments {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:[[self openFiles] count]];
	
	for (WCFile *file in [self openFiles]) {
		WCSourceFileDocument *sfDocument = [[self filesToSourceFileDocuments] objectForKey:file];
		
		if (sfDocument)
			[retval addObject:sfDocument];
	}
	
	return [[retval copy] autorelease];
}
@synthesize UUIDsToFiles=_UUIDsToFiles;
@synthesize projectSettingsProviders=_projectSettingsProviders;
@synthesize projectSettings=_projectSettings;
#pragma mark *** Private Methods ***
- (WCSourceFileSeparateWindowController *)_sourceFileSeparateWindowControllerForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
	for (id windowController in [self windowControllers]) {
		if ([windowController respondsToSelector:@selector(sourceFileDocument)] &&
			[windowController sourceFileDocument] == sourceFileDocument)
			return windowController;
	}
	return nil;
}
@synthesize fileCompletions=_fileCompletions;
@synthesize buildTargets=_buildTargets;
@dynamic mutableBuildTargets;
- (NSMutableArray *)mutableBuildTargets {
	return [self mutableArrayValueForKey:@"buildTargets"];
}
- (NSUInteger)countOfBuildTargets {
	return [_buildTargets count];
}
- (NSArray *)buildTargetsAtIndexes:(NSIndexSet *)indexes {
	return [_buildTargets objectsAtIndexes:indexes];
}
- (void)insertBuildTargets:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_buildTargets insertObjects:array atIndexes:indexes];
}
- (void)removeBuildTargetsAtIndexes:(NSIndexSet *)indexes {
	[_buildTargets removeObjectsAtIndexes:indexes];
}
- (void)replaceBuildTargetsAtIndexes:(NSIndexSet *)indexes withBuildTargets:(NSArray *)array {
	[_buildTargets replaceObjectsAtIndexes:indexes withObjects:array];
}
@dynamic activeBuildTarget;
- (WCBuildTarget *)activeBuildTarget {
	for (WCBuildTarget *buildTarget in [self buildTargets]) {
		if ([buildTarget isActive])
			return buildTarget;
	}
	return nil;
}
- (void)setActiveBuildTarget:(WCBuildTarget *)activeBuildTarget {
	for (WCBuildTarget *buildTarget in [self buildTargets]) {
		if (buildTarget == activeBuildTarget)
			[buildTarget setActive:YES];
		else
			[buildTarget setActive:NO];
	}
}
@dynamic buildController;
- (WCBuildController *)buildController {
	if (!_buildController) {
		_buildController = [[WCBuildController alloc] initWithProjectDocument:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:_buildController];
	}
	return _buildController;
}
@dynamic breakpointManager;
- (WCBreakpointManager *)breakpointManager {
	if (!_breakpointManager)
		_breakpointManager = [[WCBreakpointManager alloc] initWithProjectDocument:self];
	return _breakpointManager;
}
@dynamic debugController;
- (WCDebugController *)debugController {
	if (!_debugController)
		_debugController = [[WCDebugController alloc] initWithProjectDocument:self];
	return _debugController;
}
@dynamic calculatorWindowController;
- (WCCalculatorWindowController *)calculatorWindowController {
	WCCalculatorWindowController *retval = nil;
	
	for (id windowController in [self windowControllers]) {
		if ([windowController isKindOfClass:[WCCalculatorWindowController class]]) {
			retval = windowController;
			break;
		}
	}
	
	if (!retval) {
		WCCalculatorWindowController *windowController = [[[WCCalculatorWindowController alloc] initWithCalculator:[[self debugController] calculator]] autorelease];
		
		[self addWindowController:windowController];
		
		retval = windowController;
	}
	
	return retval;
}

#pragma mark Notifications
- (void)_projectNavigatorDidAddNewGroup:(NSNotification *)note {
	WCGroupContainer *newGroupContainer = [[note userInfo] objectForKey:WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey];
	
	[[self filesToFileContainers] setObject:newGroupContainer forKey:[newGroupContainer representedObject]];
}
- (void)_projectNavigatorDidAddNodes:(NSNotification *)note {
	NSArray *newFileContainers = [[note userInfo] objectForKey:WCProjectNavigatorDidAddNodesNotificationNewNodesUserInfoKey];
	
	for (WCFileContainer *newFileContainer in newFileContainers) {
		[[self filesToFileContainers] setObject:newFileContainer forKey:[newFileContainer representedObject]];
		
		if ([[newFileContainer representedObject] isSourceFile]) {
			NSError *outError;
			WCSourceFileDocument *document = [[[WCSourceFileDocument alloc] initWithContentsOfURL:[[newFileContainer representedObject] fileURL] ofType:[[newFileContainer representedObject] fileUTI] error:&outError] autorelease];
			[document setProjectDocument:self];
			
			if (document) {
				[[self filesToSourceFileDocuments] setObject:document forKey:[newFileContainer representedObject]];
				[[self sourceFileDocumentsToFiles] setObject:[newFileContainer representedObject] forKey:document];
			}
		}
		
		if ([newFileContainer isLeafNode])
			[_fileCompletions setObject:[newFileContainer representedObject] forKey:[[[newFileContainer representedObject] fileName] lowercaseString]];
		
		[[self UUIDsToFiles] setObject:[newFileContainer representedObject] forKey:[[newFileContainer representedObject] UUID]];
	}
}
- (void)_projectNavigatorDidRemoveNodes:(NSNotification *)note {
	NSSet *removedFileContainers = [[note userInfo] objectForKey:WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey];
	
	for (WCFileContainer *fileContainer in removedFileContainers)
		[[self filesToFileContainers] removeObjectForKey:[fileContainer representedObject]];
	
	[_fileCompletions removeAllObjects];
	
	for (WCFileContainer *fileContainer in [[self projectContainer] descendantLeafNodes])
		[_fileCompletions setObject:[fileContainer representedObject] forKey:[[[fileContainer representedObject] fileName] lowercaseString]];
}
- (void)_windowWillClose:(NSNotification *)note {
	for (WCFile *file in [[self filesToSourceFileDocuments] keyEnumerator])
		[NSFileCoordinator removeFilePresenter:[file fileReference]];
	
	for (WCBuildTarget *buildTarget in [self buildTargets]) {
		for (WCBuildInclude *buildInclude in [buildTarget includes])
			[NSFileCoordinator removeFilePresenter:[buildInclude fileReference]];
	}
	
	[[self breakpointManager] performCleanup];
	[[self buildController] performCleanup];
	
	[[[self projectContainer] representedObject] performCleanup];
}
- (void)_buildControllerDidFinishBuilding:(NSNotification *)note {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WCBuildControllerDidFinishBuildingNotification object:nil];
	
	[[[self projectWindowController] navigatorControl] setSelectedItemIdentifier:@"issue"];
}
@end
