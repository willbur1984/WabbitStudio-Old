//
//  WCNewFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCNewFileWindowController.h"
#import "WCProjectDocument.h"
#import "WCFileTemplate.h"
#import "WCTemplateCategory.h"
#import "WCMiscellaneousPerformer.h"
#import "KBResponderNotifyingWindow.h"
#import "RSDefines.h"
#import "NSString+WCExtensions.h"
#import "WCFile.h"
#import "WCDocumentController.h"
#import "WCProjectWindowController.h"
#import "WCProjectNavigatorViewController.h"
#import "NSURL+RSExtensions.h"
#import "WCFileContainer.h"
#import "NSArray+WCExtensions.h"
#import "RSNavigatorControl.h"

@interface WCNewFileWindowController ()
@property (readonly,nonatomic) WCFileTemplate *selectedFileTemplate;
@property (readwrite,copy,nonatomic) NSURL *savePanelURL;

- (void)_createFileTemplateAndInsertIntoProjectDocument;
- (void)_loadApplicationFileTemplates;
- (void)_loadUserFileTemplates;
@end

@implementation WCNewFileWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[_savePanelURL release];
	[_categories release];
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WCNewFileWindow";
}

- (void)windowWillLoad {
	[super windowWillLoad];
	
	[self _loadApplicationFileTemplates];
	[self _loadUserFileTemplates];
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
+ (WCNewFileWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] initWithProjectDocument:nil];
	});
	return sharedInstance;
}

+ (id)newFileWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithProjectDocument:projectDocument] autorelease];
}
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_projectDocument = projectDocument;
	_categories = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}

- (void)showNewFileWindow; {
	if ([self projectDocument]) {
		// so clang will shut up
		[self performSelector:@selector(retain)];
		
		[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
	}
	else {
		NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
		
		if (result == NSCancelButton)
			return;
		
		[self _createFileTemplateAndInsertIntoProjectDocument];
	}
}

- (BOOL)createFileAtURL:(NSURL *)fileURL withFileTemplate:(WCFileTemplate *)fileTemplate error:(NSError **)outError; {	
	NSURL *templateFileURL = [[[fileTemplate URL] parentDirectoryURL] URLByAppendingPathComponent:[fileTemplate mainFileName]];
	
	if (![templateFileURL checkResourceIsReachableAndReturnError:outError])
		return NO;
	
	NSStringEncoding templateFileStringEncoding;
	NSString *templateFileString = [NSString stringWithContentsOfURL:templateFileURL usedEncoding:&templateFileStringEncoding error:outError];
	
	if (!templateFileString) {
		templateFileStringEncoding = [fileTemplate mainFileEncoding];
		templateFileString = [NSString stringWithContentsOfURL:templateFileURL encoding:templateFileStringEncoding error:outError];
		
		if (!templateFileString)
			return NO;
	}
	
	NSString *projectName = ([self projectDocument])?[[self projectDocument] displayName]:NSLocalizedString(@"No Project", @"No Project");
	
	templateFileString = [templateFileString stringByReplacingFileTemplatePlaceholdersWithValuesDictionary:[NSDictionary dictionaryWithObjectsAndKeys:projectName,WCFileTemplateProjectNameValueKey,[fileURL lastPathComponent],WCFileTemplateFileNameValueKey, nil]];
	
	if (![templateFileString writeToURL:fileURL atomically:YES encoding:templateFileStringEncoding error:outError])
		return NO;
	
	return YES;
}
#pragma mark IBActions
- (IBAction)cancel:(id)sender; {
	if ([self projectDocument])
		[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
	else {
		[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
		[[self window] orderOut:nil];
	}
}
- (IBAction)create:(id)sender; {
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	WCFileTemplate *fileTemplate = [self selectedFileTemplate];
	
	[savePanel setAllowedFileTypes:[fileTemplate allowedFileTypes]];
	[savePanel setAllowsOtherFileTypes:NO];
	
	[savePanel setCanCreateDirectories:YES];
	[savePanel setPrompt:LOCALIZED_STRING_CREATE];
	[savePanel setMessage:NSLocalizedString(@"Choose a location and name for your new file.", @"Choose a location and name for your new file.")];
	
	[savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		[savePanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		[self setSavePanelURL:[savePanel URL]];
		
		if ([self projectDocument])
			[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
		else {
			[[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
			[[self window] orderOut:nil];
		}
	}];
}

#pragma mark Properties
@synthesize tableView=_tableView;
@synthesize categoriesArrayController=_categoriesArrayController;
@synthesize collectionView=_collectionView;
@synthesize splitterHandleImageView=_splitterHandleImageView;
@synthesize templatesArrayController=_templatesArrayController;
@synthesize savePanelURL=_savePanelURL;

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
@synthesize projectDocument=_projectDocument;

#pragma mark *** Private Methods ***
- (void)_createFileTemplateAndInsertIntoProjectDocument {
	NSError *outError;
	if (![self createFileAtURL:[self savePanelURL] withFileTemplate:[self selectedFileTemplate] error:&outError]) {
		[[NSApplication sharedApplication] presentError:outError];
		return;
	}
	
	if ([self projectDocument]) {
		WCProjectNavigatorViewController *projectNavigatorViewController = [[[self projectDocument] projectWindowController] projectNavigatorViewController];
		// grab the first selected node
		WCFileContainer *selectedFileContainer = [[projectNavigatorViewController selectedObjects] firstObject];
		NSUInteger insertIndex = 0;
		
		// if the node is a leaf node, adjust the insertion index and node appropriately
		if ([selectedFileContainer isLeafNode]) {
			insertIndex = [[[selectedFileContainer parentNode] childNodes] indexOfObjectIdenticalTo:selectedFileContainer] + 1;
			selectedFileContainer = [selectedFileContainer parentNode];
		}
		
		// select the project navigator
		[[[[self projectDocument] projectWindowController] navigatorControl] setSelectedItemIdentifier:WCProjectWindowNavigatorControlProjectItemIdentifier];
		
		// create our new file and file container
		WCFile *file = [WCFile fileWithFileURL:[self savePanelURL]];
		WCFileContainer *fileContainer = [WCFileContainer fileContainerWithFile:file];
		
		// insert the new file into the outline view
		[[selectedFileContainer mutableChildNodes] insertObject:fileContainer atIndex:insertIndex];
		
		// select the new file
		[projectNavigatorViewController setSelectedObjects:[NSArray arrayWithObjects:fileContainer, nil]];
		
		// post the appropriate notification
		[[NSNotificationCenter defaultCenter] postNotificationName:WCProjectNavigatorDidAddNodesNotification object:projectNavigatorViewController userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:fileContainer, nil],WCProjectNavigatorDidAddNodesNotificationNewNodesUserInfoKey, nil]];
		
		// open a new tab for the file
		[[self projectDocument] openTabForFile:file tabViewContext:nil];
		
		// let the document know there was a change
		[[self projectDocument] updateChangeCount:NSChangeDone];
	}
	else {
		[[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[self savePanelURL] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
			if (error)
				[[NSApplication sharedApplication] presentError:error];
		}];
	}
}

- (void)_loadApplicationFileTemplates; {
	WCTemplateCategory *applicationCategories = [WCTemplateCategory templateCategoryWithURL:nil header:YES];
	[applicationCategories setName:NSLocalizedString(@"Built-in Templates", @"Built-in Templates")];
	[applicationCategories setIcon:[NSImage imageNamed:NSImageNameComputer]];
	
	[_categories addObject:applicationCategories];
	
	NSDirectoryEnumerator *categoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[WCMiscellaneousPerformer sharedPerformer] applicationFileTemplatesDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
		return YES;
	}];
	
	for (NSURL *categoryURL in categoryEnumerator) {
		WCTemplateCategory *category = [WCTemplateCategory templateCategoryWithURL:categoryURL];
		
		[_categories addObject:category];
		
		NSDirectoryEnumerator *templateEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:categoryURL includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
			return YES;
		}];
		
		for (NSURL *templateURL in templateEnumerator) {
			NSError *outError;
			WCFileTemplate *template = [WCFileTemplate fileTemplateWithURL:templateURL error:&outError];
			
			if (template) {
				[template setIcon:[NSImage imageNamed:@"assembly"]];
				[[category mutableChildNodes] addObject:template];
			}
			else if (outError)
				[[NSApplication sharedApplication] presentError:outError];
		}
	}
}
- (void)_loadUserFileTemplates; {
	NSMutableArray *userTemplates = [NSMutableArray arrayWithCapacity:0];
	NSDirectoryEnumerator *categoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[WCMiscellaneousPerformer sharedPerformer] userFileTemplatesDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
		return YES;
	}];
	
	for (NSURL *categoryURL in categoryEnumerator) {
		WCTemplateCategory *category = [WCTemplateCategory templateCategoryWithURL:categoryURL];
		
		NSDirectoryEnumerator *templateEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:categoryURL includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
			return YES;
		}];
		
		for (NSURL *templateURL in templateEnumerator) {
			WCFileTemplate *template = [WCFileTemplate fileTemplateWithURL:templateURL error:NULL];
			
			if (template) {
				[template setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:[[template allowedFileTypes] lastObject]]];
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
@dynamic selectedFileTemplate;
- (WCFileTemplate *)selectedFileTemplate {
	return [[[self templatesArrayController] selectedObjects] lastObject];
}

#pragma mark Notifications
- (void)_firstResponderDidChange:(NSNotification *)note {
	[[self collectionView] setNeedsDisplay:YES];
}

#pragma mark Callbacks
- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context; {
	// to balance the retain in the showNewFileWindow method
	[self autorelease];
	[sheet orderOut:nil];
	if (code == NSCancelButton)
		return;
	
	[self _createFileTemplateAndInsertIntoProjectDocument];
}

@end
