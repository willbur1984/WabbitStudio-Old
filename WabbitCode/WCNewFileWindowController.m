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

@interface WCNewFileWindowController ()
@property (readonly,nonatomic) WCFileTemplate *selectedFileTemplate;
@property (readwrite,copy,nonatomic) NSURL *savePanelURL;

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
		
		NSError *outError;
		if (![self createFileAtURL:[self savePanelURL] withFileTemplate:[self selectedFileTemplate] error:&outError]) {
			[[NSApplication sharedApplication] presentError:outError];
			return;
		}
		
		if ([self projectDocument]) {
			// TODO: create a new WCFile and add it to the project
		}
		else {
			[[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[self savePanelURL] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
				if (error)
					[[NSApplication sharedApplication] presentError:error];
			}];
		}
	}
}

- (BOOL)createFileAtURL:(NSURL *)fileURL withFileTemplate:(WCFileTemplate *)fileTemplate error:(NSError **)outError; {
	NSURL *templateFileURL = [[[fileTemplate URL] URLByAppendingPathComponent:[fileTemplate mainFileName]] URLByAppendingPathExtension:[[fileTemplate allowedFileTypes] objectAtIndex:0]];
	
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
	
	templateFileString = [templateFileString stringByReplacingFileTemplatePlaceholdersWithValuesDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[[self projectDocument] displayName],WCFileTemplateProjectNameValueKey,[fileURL lastPathComponent],WCFileTemplateFileNameValueKey, nil]];
	
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
	
	// TODO: create our new file
}

@end
