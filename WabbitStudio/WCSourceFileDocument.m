//
//  WCDocument.m
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceFileDocument.h"
#import "WCSourceScanner.h"
#import "WCSourceHighlighter.h"
#import "WCJumpBarViewController.h"
#import "WCSourceTextStorage.h"
#import "WCStandardSourceTextViewController.h"
#import "WCSourceTextView.h"
#import "RSFindBarViewController.h"
#import "NSString+RSExtensions.h"
#import "WCEditorViewController.h"
#import "NSUserDefaults+RSExtensions.h"
#import "WCDocumentController.h"
#import "WCSourceFileWindowController.h"
#import "WCProjectDocument.h"
#import "NDTrie.h"
#import "WCProjectContainer.h"
#import "WCFileContainer.h"
#import "WCProject.h"
#import "UKXattrMetadataStore.h"
#import "NSTextView+WCExtensions.h"
#import "WCJumpBarComponentCell.h"
#import "NSURL+RSExtensions.h"
#import "NSImage+RSExtensions.h"
#import "RSDefines.h"
#import "RSFileReference.h"

NSString *const WCSourceFileDocumentWindowFrameKey = @"org.revsoft.wabbitstudio.windowframe";
NSString *const WCSourceFileDocumentSelectedRangeKey = @"org.revsoft.wabbitstudio.selectedrange";
NSString *const WCSourceFileDocumentStringEncodingKey = @"org.revsoft.wabbitstudio.stringencoding";
NSString *const WCSourceFileDocumentVisibleRangeKey = @"org.revsoft.wabbitstudio.visiblerange";

@interface WCSourceFileDocument ()
@property (readonly,nonatomic) NSImage *icon;
@property (readonly,nonatomic) BOOL isEdited;

- (void)_updateFileEditedStatus;
@end

@implementation WCSourceFileDocument
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[_sourceHighlighter release];
	[_sourceScanner release];
	[_textStorage release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_fileEncoding = [[NSUserDefaults standardUserDefaults] unsignedIntegerForKey:WCEditorDefaultTextEncodingKey];
	_textStorage = [[WCSourceTextStorage alloc] initWithString:@""];
	[_textStorage setDelegate:self];
	_sourceScanner = [[WCSourceScanner alloc] initWithTextStorage:[self textStorage]];
	[_sourceScanner setDelegate:self];
	[_sourceScanner setNeedsToScanSymbols:YES];
	
	_sourceHighlighter = [[WCSourceHighlighter alloc] initWithSourceScanner:[self sourceScanner]];
	[_sourceHighlighter setDelegate:self];
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCSourceFileDocument";
}

- (void)makeWindowControllers {
	WCSourceFileWindowController *windowController = [[[WCSourceFileWindowController alloc] init] autorelease];
	
	[self addWindowController:windowController];
}

+ (BOOL)autosavesInPlace {
    return NO;
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
	if ([typeName isEqualToString:WCAssemblyFileUTI] ||
		[typeName isEqualToString:WCIncludeFileUTI] ||
		[typeName isEqualToString:WCActiveServerIncludeFileUTI])
		return YES;
	return NO;
}

- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation {
	if ([typeName isEqualToString:WCAssemblyFileUTI] ||
		[typeName isEqualToString:WCIncludeFileUTI] ||
		[typeName isEqualToString:WCActiveServerIncludeFileUTI])
		return YES;
	return NO;
}

- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
	if (saveOperation != NSAutosaveInPlaceOperation) {
		if ([self projectDocument]) {
			
		}
		else
			[[[[self windowControllers] objectAtIndex:0] sourceTextViewController] breakUndoCoalescingForAllTextViews];
	}
	
	[super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:^(NSError *outError) {
		if (saveOperation != NSAutosaveInPlaceOperation)
			[self _updateFileEditedStatus];
		
		completionHandler(outError);
	}];
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSMutableString *string = [[[[self textStorage] string] mutableCopy] autorelease];
	NSStringEncoding fileEncoding = _fileEncoding;
	
	[self unblockUserInteraction];
	
	// remove any attachment characters
	[string replaceOccurrencesOfString:[NSString attachmentCharacterString] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	
	// fix our line endings if the user requested it
	if ([[NSUserDefaults standardUserDefaults] boolForKey:WCEditorConvertExistingFileLineEndingsOnSaveKey]) {
		WCEditorDefaultLineEndings lineEnding = [[[NSUserDefaults standardUserDefaults] objectForKey:WCEditorDefaultLineEndingsKey] unsignedIntValue];
		switch (lineEnding) {
			case WCEditorDefaultLineEndingsUnix:
				[string replaceOccurrencesOfString:[NSString windowsLineEndingString] withString:[NSString unixLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				[string replaceOccurrencesOfString:[NSString macOSLineEndingString] withString:[NSString unixLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				break;
			case WCEditorDefaultLineEndingsMacOS:
				[string replaceOccurrencesOfString:[NSString windowsLineEndingString] withString:[NSString macOSLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				[string replaceOccurrencesOfString:[NSString unixLineEndingString] withString:[NSString macOSLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				break;
			case WCEditorDefaultLineEndingsWindows:
				[string replaceOccurrencesOfString:[NSString windowsLineEndingString] withString:[NSString unixLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				[string replaceOccurrencesOfString:[NSString macOSLineEndingString] withString:[NSString unixLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				[string replaceOccurrencesOfString:[NSString unixLineEndingString] withString:[NSString windowsLineEndingString] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
				break;
			default:
				break;
		}
	}
	
	if (![[string dataUsingEncoding:fileEncoding] writeToURL:url options:NSDataWritingAtomic error:outError])
		return NO;
	
	[UKXattrMetadataStore setObject:[NSNumber numberWithUnsignedInteger:fileEncoding] forKey:WCSourceFileDocumentStringEncodingKey atPath:[url path] traverseLink:NO];
	
	if ([self projectDocument]) {
		
	}
	else if ([[self windowControllers] count]) {
		NSString *selectedRangeString = NSStringFromRange([[[[[self windowControllers] objectAtIndex:0] sourceTextViewController] textView] selectedRange]);
		NSString *visibleRangeString = NSStringFromRange([[[[[self windowControllers] objectAtIndex:0] sourceTextViewController] textView] visibleRange]);
		NSString *windowFrameString = [[[[self windowControllers] objectAtIndex:0] window] stringWithSavedFrame];
		
		[UKXattrMetadataStore setString:visibleRangeString forKey:WCSourceFileDocumentVisibleRangeKey atPath:[url path] traverseLink:NO];
		[UKXattrMetadataStore setString:windowFrameString forKey:WCSourceFileDocumentWindowFrameKey atPath:[url path] traverseLink:NO];
		[UKXattrMetadataStore setString:selectedRangeString forKey:WCSourceFileDocumentSelectedRangeKey atPath:[url path] traverseLink:NO];
	}
	
	return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSStringEncoding stringEncoding = [[UKXattrMetadataStore objectForKey:WCSourceFileDocumentStringEncodingKey atPath:[url path] traverseLink:NO] unsignedIntegerValue];
	if (!stringEncoding)
		stringEncoding = _fileEncoding;
	
	NSString *string = [NSString stringWithContentsOfURL:url encoding:stringEncoding error:outError];
	
	if (!string)
		return NO;
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withString:string];
	[_sourceScanner scanTokens];
	
	return YES;
}

- (void)updateChangeCount:(NSDocumentChangeType)change {
	BOOL wasDocumentEdited = [self isDocumentEdited];
	
	[super updateChangeCount:change];
	
	if (wasDocumentEdited != [self isDocumentEdited] && change != NSChangeCleared)
		[self _updateFileEditedStatus];
}

- (void)setFileURL:(NSURL *)url {
	[super setFileURL:url];
	
	if ([self projectDocument])
		[self _updateFileEditedStatus];
}

- (void)saveDocument:(id)sender {
	if ([self projectDocument]) {
		WCFile *file = [[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self];
		
		[[file fileReference] setIgnoreNextFileWatcherNotification:YES];
	}
	
	[super saveDocument:nil];
}
#pragma mark PSMTabBarControlCell
@dynamic icon;
- (NSImage *)icon {
	NSImage *retval;
	WCFile *file = [[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self];
	if (file)
		retval = [file fileIcon];
	else {
		if ([self fileURL])
			retval = [[self fileURL] fileIcon];
		else
			retval = [NSImage imageNamed:@"UntitledFile"];
		
		if ([self isDocumentEdited])
			retval = [retval unsavedImageFromImage];
	}
	
	[retval setSize:NSSmallSize];
	
	return retval;
}
@dynamic isEdited;
- (BOOL)isEdited {
	return [self isDocumentEdited];
}
#pragma mark WCJumpBarDataSource
- (NSArray *)jumpBarComponentCells {
	if ([self projectDocument]) {
		WCFile *fileForDocument = [[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self];
		WCFileContainer *treeNodeForDocument = [[self projectDocument] fileContainerForFile:fileForDocument];
		
		WCJumpBarComponentCell *fileCell = [[[WCJumpBarComponentCell alloc] initTextCell:[fileForDocument fileName]] autorelease];
		[fileCell setImage:[self icon]];
		[fileCell setRepresentedObject:fileForDocument];
		
		NSMutableArray *retval = [NSMutableArray arrayWithObjects:fileCell, nil];
		while ([treeNodeForDocument parentNode]) {
			WCFile *file = [[treeNodeForDocument parentNode] representedObject];
			WCJumpBarComponentCell *cell = [[[WCJumpBarComponentCell alloc] initTextCell:[file fileName]] autorelease];
			[cell setImage:[file fileIcon]];
			[cell setRepresentedObject:file];
			
			[retval insertObject:cell atIndex:0];
			
			treeNodeForDocument = [treeNodeForDocument parentNode];
		}
		return [[retval copy] autorelease];
	}
	return [NSArray arrayWithObjects:[self fileComponentCell], nil];
}
- (WCJumpBarComponentCell *)fileComponentCell {
	if ([self projectDocument]) {
		WCFile *fileForDocument = [[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self];
		
		WCJumpBarComponentCell *cell = [[[WCJumpBarComponentCell alloc] initTextCell:[fileForDocument fileName]] autorelease];
		[cell setImage:[fileForDocument fileIcon]];
		[cell setRepresentedObject:fileForDocument];
		
		return cell;
	}
	else {
		WCJumpBarComponentCell *cell = [[[WCJumpBarComponentCell alloc] initTextCell:[self displayName]] autorelease];
		
		[cell setImage:[self icon]];
		
		return cell;
	}
}
#pragma mark WCSourceScannerDelegate
- (NSArray *)sourceScanner:(WCSourceScanner *)scanner completionsForPrefix:(NSString *)prefix; {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObjectsFromArray:[[[document sourceScanner] completions] everyObjectForKeyWithPrefix:prefix]];
	}
	else
		[retval addObjectsFromArray:[[scanner completions] everyObjectForKeyWithPrefix:prefix]];
	
	return [[retval copy] autorelease];
}
- (NSString *)fileDisplayNameForSourceScanner:(WCSourceScanner *)scanner {
	return [self displayName];
}
- (WCSourceFileDocument *)sourceFileDocumentForSourceScanner:(WCSourceScanner *)scanner {
	return self;
}
- (NSURL *)fileURLForSourceScanner:(WCSourceScanner *)scanner {
	return [self fileURL];
}
- (NSURL *)locationURLForSourceScanner:(WCSourceScanner *)scanner {
	NSArray *jumpBarComponents = [self jumpBarComponentCells];
	NSURL *retval = [NSURL URLWithString:[[[jumpBarComponents objectAtIndex:0] representedObject] fileName]];
	
	for (RSTreeNode *treeNode in [jumpBarComponents subarrayWithRange:NSMakeRange(1, [jumpBarComponents count]-1)]) {
		retval = [retval URLByAppendingPathComponent:[[treeNode representedObject] fileName]];
	}
	return retval;
}
#pragma mark WCSourceTextStorageDelegate
- (WCSourceHighlighter *)sourceHighlighterForSourceTextStorage:(WCSourceTextStorage *)textStorage {
	return [self sourceHighlighter];
}
#pragma mark WCSourceHighlighterDelegate
- (NSArray *)labelSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] labelNamesToLabelSymbols]];
	}
	else
		[retval addObject:[[self sourceScanner] labelNamesToLabelSymbols]];
	
	return [[retval copy] autorelease];
}
- (NSArray *)equateSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] equateNamesToEquateSymbols]];
	}
	else
		[retval addObject:[[self sourceScanner] equateNamesToEquateSymbols]];
	
	return [[retval copy] autorelease];
}
- (NSArray *)defineSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] defineNamesToDefineSymbols]];
	}
	else
		[retval addObject:[[self sourceScanner] defineNamesToDefineSymbols]];
	
	return [[retval copy] autorelease];
}
- (NSArray *)macroSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] macroNamesToMacroSymbols]];
	}
	else
		[retval addObject:[[self sourceScanner] macroNamesToMacroSymbols]];
	
	return [[retval copy] autorelease];
}
#pragma mark *** Public Methods ***
- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName forProjectDocument:(WCProjectDocument *)projectDocument error:(NSError **)outError; {
	if (!(self = [super initWithContentsOfURL:url ofType:typeName error:outError]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}
- (void)reloadDocumentFromDisk; {
	[[self textStorage] replaceCharactersInRange:NSMakeRange(0, [[self textStorage] length]) withString:[NSString stringWithContentsOfURL:[self fileURL] encoding:_fileEncoding error:NULL]];
	[self setFileModificationDate:[[[NSFileManager defaultManager] attributesOfItemAtPath:[[self fileURL] path] error:NULL] fileModificationDate]];
}
#pragma mark Properties
@synthesize sourceScanner=_sourceScanner;
@synthesize sourceHighlighter=_sourceHighlighter;
@synthesize textStorage=_textStorage;
@synthesize projectDocument=_projectDocument;

- (void)_updateFileEditedStatus {
	[self willChangeValueForKey:@"icon"];
	[self willChangeValueForKey:@"isEdited"];
	
	[[[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self] setEdited:[self isDocumentEdited]];
	
	[self didChangeValueForKey:@"icon"];
	[self didChangeValueForKey:@"isEdited"];
}

@end
