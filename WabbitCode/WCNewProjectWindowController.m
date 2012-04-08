//
//  WCNewProjectWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCNewProjectWindowController.h"
#import "RSDefines.h"
#import "WCDocumentController.h"
#import "WCGroup.h"
#import "WCProjectContainer.h"
#import "RSDefines.h"
#import "NSURL+RSExtensions.h"
#import "WCProjectDocument.h"
#import "GTMNSData+zlib.h"
#import "WCInterfacePerformer.h"
#import "WCProjectTemplate.h"
#import "WCTemplateCategory.h"
#import "WCMiscellaneousPerformer.h"
#import "KBResponderNotifyingWindow.h"
#import "NSString+WCExtensions.h"
#import "WCFileTemplate.h"

@interface WCNewProjectWindowController ()
@property (readonly,nonatomic) WCProjectTemplate *selectedProjectTemplate;

- (void)_loadApplicationProjectTemplates;
- (void)_loadUserProjectTemplates;
@end

@implementation WCNewProjectWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_categories = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCNewProjectWindow";
}

- (void)windowWillLoad {
	[super windowWillLoad];
	
	[self _loadApplicationProjectTemplates];
	[self _loadUserProjectTemplates];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[self categoriesArrayController] setSelectionIndexes:[NSIndexSet indexSetWithIndex:1]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_firstResponderDidChange:) name:KBWindowFirstResponderDidChangeNotification object:[self window]];
}
#pragma mark NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	WCTemplateCategory *category = [[[self categoriesArrayController] arrangedObjects] objectAtIndex:row];
	
	if ([category isHeader])
		return floor([tableView rowHeight]*2);
	return [tableView rowHeight];
}
- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
	if ([proposedSelectionIndexes containsIndex:0]) {
		if ([[tableView selectedRowIndexes] count])
			return [tableView selectedRowIndexes];
		return [NSIndexSet indexSetWithIndex:1];
	}
	return proposedSelectionIndexes;
}

static NSString *const kMainCellIdentifier = @"MainCell";
static NSString *const kHeaderCellIdentifier = @"HeaderCell";

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	WCTemplateCategory *category = [[[self categoriesArrayController] arrangedObjects] objectAtIndex:row];
	
	if ([category isHeader])
		return [tableView makeViewWithIdentifier:kHeaderCellIdentifier owner:self];
	return [tableView makeViewWithIdentifier:kMainCellIdentifier owner:self];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	if ([rowView respondsToSelector:@selector(setTableView:)])
		[(id)rowView setTableView:tableView];
}
- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	if ([rowView respondsToSelector:@selector(setTableView:)])
		[(id)rowView setTableView:nil];
}
#pragma mark RSTableViewDelegate
- (void)handleTabPressedForTableView:(RSTableView *)tableView {
	[[self window] makeFirstResponder:[self collectionView]];
}
#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
	if ([[splitView subviews] objectAtIndex:0] == view)
		return NO;
	return YES;
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
	return [splitView convertRect:[[self splitterHandleImageView] bounds] fromView:[self splitterHandleImageView]];
}
static const CGFloat kLeftSubviewMinimumWidth = 150.0;
static const CGFloat kRightSubviewMinimumWidth = 350.0;
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMaximumPosition-kRightSubviewMinimumWidth;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMinimumPosition+kLeftSubviewMinimumWidth;
}
#pragma mark RSCollectionViewDelegate
- (void)handleReturnPressedForCollectionView:(RSCollectionView *)collectionView {
	[self create:nil];
}
- (void)handleTabPressedForCollectionView:(RSCollectionView *)collectionView {
	[[self window] makeFirstResponder:[self tableView]];
}
- (void)collectionView:(RSCollectionView *)collectionView handleDoubleClickForItemsAtIndexes:(NSIndexSet *)indexes {
	[self create:nil];
}

#pragma mark *** Public Methods ***
+ (WCNewProjectWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (id)createProjectWithContentsOfDirectory:(NSURL *)directoryURL error:(NSError **)outError; {
	CFStringRef projectExtension = UTTypeCopyPreferredTagWithClass((CFStringRef)WCProjectFileUTI, kUTTagClassFilenameExtension);
	NSURL *projectURL = [directoryURL URLByAppendingPathComponent:[[directoryURL lastPathComponent] stringByAppendingPathExtension:(NSString *)projectExtension] isDirectory:NO];
	CFRelease(projectExtension);
	
	WCProjectContainer *projectNode = [WCProjectContainer projectContainerWithProject:nil];
	
	NSArray *fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey,NSURLIsPackageKey,NSURLParentDirectoryURLKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants error:outError];
	if (![[WCInterfacePerformer sharedPerformer] addFileURLs:fileURLs toGroupContainer:projectNode atIndex:0 copyFiles:NO error:outError])
		return nil;
	
	NSFileWrapper *projectWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
	NSData *projectData = [NSPropertyListSerialization dataWithPropertyList:[projectNode plistRepresentation] format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
	if (!projectData)
		return nil;
	
#ifndef DEBUG
	projectData = [NSData gtm_dataByGzippingData:projectData];
#endif
	
	[projectWrapper addRegularFileWithContents:projectData preferredFilename:WCProjectDataFileName];
	
	if (![projectWrapper writeToURL:projectURL options:NSFileWrapperWritingAtomic originalContentsURL:nil error:outError])
		return nil;
	
	return [[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:projectURL display:YES error:outError];
}

- (id)createProjectAtURL:(NSURL *)projectURL withProjectTemplate:(WCProjectTemplate *)projectTemplate error:(NSError **)outError; {
	NSURL *projectDirectoryURL = [projectURL URLByDeletingPathExtension];
	// create a directory for the project, use the file name as the directory name (chop off the file extension)
	if (![[NSFileManager defaultManager] createDirectoryAtURL:projectDirectoryURL withIntermediateDirectories:YES attributes:nil error:outError])
		return nil;
	
	NSDirectoryEnumerator *templateDirectoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[projectTemplate URL] parentDirectoryURL] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLTypeIdentifierKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
		// ignore any errors and just keep processing
		return YES;
	}];
	
	NSURL *applicationIncludeFilesDirectoryURL = [[WCMiscellaneousPerformer sharedPerformer] applicationIncludeFilesDirectoryURL];				
	// first copy any include files that the project template requires
	for (NSString *includeFileName in [projectTemplate includeFiles]) {
		NSURL *includeFileURL = [applicationIncludeFilesDirectoryURL URLByAppendingPathComponent:includeFileName];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:[includeFileURL path]])
			continue;
		
		[[NSFileManager defaultManager] copyItemAtURL:includeFileURL toURL:[projectDirectoryURL URLByAppendingPathComponent:includeFileName] error:outError];
	}
	
	static NSString *const kPropertyListUTI = @"com.apple.property-list";
	NSDictionary *templateValues = [NSDictionary dictionaryWithObjectsAndKeys:[projectURL lastPathComponent],WCFileTemplateProjectNameValueKey,[projectTemplate includeFiles],WCFileTemplateIncludeFileNamesValueKey, nil];
	// copy everything over that isnt a plist (this ensures the TemplateInfo.plist file is ignored)
	for (NSURL *fileURL in templateDirectoryEnumerator) {
		NSString *fileUTI = [fileURL fileUTI];
		
		if ([fileUTI isEqualToString:kPropertyListUTI])
			continue;
		else if ([fileUTI isEqualToString:WCAssemblyFileUTI] ||
				 [fileUTI isEqualToString:WCIncludeFileUTI] ||
				 [fileUTI isEqualToString:WCActiveServerIncludeFileUTI]) {
			
			// run any source code files through template processing
			NSMutableDictionary *fileTemplateValues = [[templateValues mutableCopy] autorelease];
			
			[fileTemplateValues setObject:[fileURL lastPathComponent] forKey:WCFileTemplateFileNameValueKey];
			
			NSStringEncoding stringEncoding;
			NSString *fileString = [NSString stringWithContentsOfURL:fileURL usedEncoding:&stringEncoding error:outError];
			
			if (!fileString)
				continue;
			
			fileString = [fileString stringByReplacingFileTemplatePlaceholdersWithValuesDictionary:fileTemplateValues];
			
			[fileString writeToURL:[projectDirectoryURL URLByAppendingPathComponent:[fileURL lastPathComponent]] atomically:YES encoding:stringEncoding error:outError];
		}
		else {
			[[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[projectDirectoryURL URLByAppendingPathComponent:[fileURL lastPathComponent]] error:outError];
		}
	}
	
	WCProjectDocument *projectDocument = [self createProjectWithContentsOfDirectory:projectDirectoryURL error:outError];
	
	if (!projectDocument)
		return nil;
	
	WCBuildTarget *buildTarget = [WCBuildTarget buildTargetWithName:NSLocalizedString(@"New Target", @"New Target") outputType:[projectTemplate outputType] projectDocument:projectDocument];
	
	[[projectDocument mutableBuildTargets] addObject:buildTarget];
	[buildTarget setActive:YES];
	
	return projectDocument;
}
#pragma mark IBActions
- (IBAction)cancel:(id)sender; {
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
	[[self window] orderOut:nil];
}
- (IBAction)createFromFolder:(id)sender; {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setMessage:NSLocalizedString(@"Choose the folder you want to create your project from.", @"Choose the folder you want to create your project from.")];
	[openPanel setPrompt:LOCALIZED_STRING_CREATE];
	
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		[openPanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		NSError *outError;
		if ([self createProjectWithContentsOfDirectory:[[openPanel URLs] lastObject] error:&outError])
			[self cancel:nil];
	}];
}
- (IBAction)create:(id)sender; {
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	
	[savePanel setAllowedFileTypes:[NSArray arrayWithObjects:WCProjectFileUTI, nil]];
	[savePanel setCanCreateDirectories:NO];
	[savePanel setPrompt:LOCALIZED_STRING_CREATE];
	[savePanel setMessage:NSLocalizedString(@"Choose a name and location for your new project.", @"Choose a name and location for your new project")];
	
	[savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		[savePanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		NSError *outError;
		if ([self createProjectAtURL:[savePanel URL] withProjectTemplate:[self selectedProjectTemplate] error:&outError])
			[self cancel:nil];
	}];
}
#pragma mark Properties
@synthesize tableView=_tableView;
@synthesize categoriesArrayController=_categoriesArrayController;
@synthesize collectionView=_collectionView;
@synthesize splitterHandleImageView=_splitterHandleImageView;
@synthesize templatesArrayController=_templatesArrayController;

@synthesize categories=_categories;
@dynamic mutableCategories;
- (NSMutableArray *)mutableCategories {
	return [self mutableArrayValueForKey:@"categories"];
}
- (NSUInteger)countOfCategories {
	return [_categories count];
}
- (NSArray *)categoriesAtIndexes:(NSIndexSet *)indexes {
	return [_categories objectsAtIndexes:indexes];
}
- (void)insertCategories:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_categories insertObjects:array atIndexes:indexes];
}
- (void)removeCategoriesAtIndexes:(NSIndexSet *)indexes {
	[_categories removeObjectsAtIndexes:indexes];
}
- (void)replaceCategoriesAtIndexes:(NSIndexSet *)indexes withCategories:(NSArray *)array {
	[_categories replaceObjectsAtIndexes:indexes withObjects:array];
}

#pragma mark *** Private Methods ***
- (void)_loadApplicationProjectTemplates; {
	WCTemplateCategory *applicationCategories = [WCTemplateCategory templateCategoryWithURL:nil header:YES];
	[applicationCategories setName:NSLocalizedString(@"Built-in Templates", @"Built-in Templates")];
	[applicationCategories setIcon:[NSImage imageNamed:NSImageNameComputer]];
	
	[_categories addObject:applicationCategories];
	
	NSDirectoryEnumerator *categoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[WCMiscellaneousPerformer sharedPerformer] applicationProjectTemplatesDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
		return YES;
	}];
	
	for (NSURL *categoryURL in categoryEnumerator) {
		WCTemplateCategory *category = [WCTemplateCategory templateCategoryWithURL:categoryURL];
		
		[_categories addObject:category];
		
		NSDirectoryEnumerator *templateEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:categoryURL includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
			return YES;
		}];
		
		for (NSURL *templateURL in templateEnumerator) {
			WCProjectTemplate *template = [WCProjectTemplate projectTemplateWithURL:templateURL];
			
			if (template) {
				[template setIcon:[NSImage imageNamed:@"project"]];
				[[category mutableChildNodes] addObject:template];
			}
		}
	}
}
- (void)_loadUserProjectTemplates; {
	NSMutableArray *userTemplates = [NSMutableArray arrayWithCapacity:0];
	NSDirectoryEnumerator *categoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[WCMiscellaneousPerformer sharedPerformer] userProjectTemplatesDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
		return YES;
	}];
	
	for (NSURL *categoryURL in categoryEnumerator) {
		WCTemplateCategory *category = [WCTemplateCategory templateCategoryWithURL:categoryURL];
		
		NSDirectoryEnumerator *templateEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:categoryURL includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
			return YES;
		}];
		
		for (NSURL *templateURL in templateEnumerator) {
			WCProjectTemplate *template = [WCProjectTemplate projectTemplateWithURL:templateURL];
			
			if (template) {
				[template setIcon:[NSImage imageNamed:@"project"]];
				[[category mutableChildNodes] addObject:template];
			}
		}
		
		if ([[category childNodes] count])
			[userTemplates addObject:category];
	}
	
	if ([userTemplates count]) {
		WCTemplateCategory *userCategories = [WCTemplateCategory templateCategoryWithURL:nil header:YES];
		
		[userCategories setName:NSLocalizedString(@"User Templates", @"User Templates")];
		[userCategories setIcon:[NSImage imageNamed:NSImageNameUser]];
		
		[_categories addObject:userCategories];
		[_categories addObjectsFromArray:userTemplates];
	}
}
#pragma mark Properties
@dynamic selectedProjectTemplate;
- (WCProjectTemplate *)selectedProjectTemplate {
	return [[[self templatesArrayController] selectedObjects] lastObject];
}

#pragma mark Notifications
- (void)_firstResponderDidChange:(NSNotification *)note {
	[[self collectionView] setNeedsDisplay:YES];
}
@end
