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

@interface WCNewProjectWindowController ()
@property (readonly,nonatomic) WCProjectTemplate *selectedProjectTemplate;
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
#pragma mark NSSplitViewDelegate
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
	WCProjectContainer *projectNode = [WCProjectContainer projectContainerWithProject:nil];
	
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
	[savePanel setCanCreateDirectories:YES];
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
@synthesize categoriesArrayController=_categoriesArrayController;
@synthesize collectionView=_collectionView;
@synthesize splitterHandleImageView=_splitterHandleImageView;

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

#pragma mark Notifications
- (void)_firstResponderDidChange:(NSNotification *)note {
	[[self collectionView] setNeedsDisplay:YES];
}
@end
