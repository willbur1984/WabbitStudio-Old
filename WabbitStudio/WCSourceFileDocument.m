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
@property (readwrite,retain) WCSourceTextStorage *textStorage;
@property (readwrite,retain) WCSourceScanner *sourceScanner;
@property (readwrite,retain) WCSourceHighlighter *sourceHighlighter;
@property (readwrite,assign) NSStringEncoding fileEncoding;
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (_undoTextView) {
		[_textStorage removeLayoutManager:[_undoTextView layoutManager]];
		[_undoTextView release];
	}
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
	
	return self;
}

// this only gets called when a new document is created
- (id)initWithType:(NSString *)typeName error:(NSError **)outError {
	if (!(self = [super initWithType:typeName error:outError]))
		return nil;
	
	_textStorage = [[WCSourceTextStorage alloc] initWithString:@""];
	[_textStorage setDelegate:self];
	_sourceScanner = [[WCSourceScanner alloc] initWithTextStorage:[self textStorage]];
	[_sourceScanner setDelegate:self];
	[_sourceScanner setNeedsToScanSymbols:YES];
	
	_sourceHighlighter = [[WCSourceHighlighter alloc] initWithSourceScanner:[self sourceScanner]];
	[_sourceHighlighter setDelegate:self];
	
	return self;
}

- (void)makeWindowControllers {
	WCSourceFileWindowController *windowController = [[[WCSourceFileWindowController alloc] init] autorelease];
	
	[windowController setShouldCloseDocument:YES];
	
	[self addWindowController:windowController];
}

+ (BOOL)autosavesInPlace {
    return YES;
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

- (BOOL)checkAutosavingSafetyAndReturnError:(NSError **)outError {
	if ([self projectDocument])
		return YES;
	return [super checkAutosavingSafetyAndReturnError:outError];
}

- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
	if (saveOperation != NSAutosaveInPlaceOperation) {
		for (NSLayoutManager *layoutManager in [[self textStorage] layoutManagers]) {
			for (NSTextContainer *textContainer in [layoutManager textContainers]) {
				NSTextView *textView = [textContainer textView];
				
				if ([textView isCoalescingUndo])
					[textView breakUndoCoalescing];
			}
		}
	}
	
	[super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:^(NSError *outError) {
		if (saveOperation != NSAutosaveInPlaceOperation)
			[self _updateFileEditedStatus];
		
		if ([self projectDocument]) {
			WCFile *file = [[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self];
			
			[[file fileReference] setShouldMonitorFile:YES];
		}
		
		completionHandler(outError);
	}];
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableString *string = [[[[self textStorage] string] mutableCopy] autorelease];
	NSStringEncoding fileEncoding = [self fileEncoding];
	
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
	
	if (![[string dataUsingEncoding:fileEncoding] writeToURL:url options:NSDataWritingAtomic error:outError]) {
		[pool release];
		return NO;
	}
	
	[pool release];
	return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSStringEncoding stringEncoding = [[NSUserDefaults standardUserDefaults] unsignedIntegerForKey:WCEditorDefaultTextEncodingKey];
	
	NSString *string = [NSString stringWithContentsOfURL:url encoding:stringEncoding error:outError];
	
	if (!string) {
		[pool release];
		return NO;
	}
	
	[self setFileEncoding:stringEncoding];
	
	[self setTextStorage:[[[WCSourceTextStorage alloc] initWithString:string] autorelease]];
	[[self textStorage] setDelegate:self];
	[self setSourceScanner:[[[WCSourceScanner alloc] initWithTextStorage:[self textStorage]] autorelease]];
	[[self sourceScanner] setDelegate:self];
	[[self sourceScanner] setNeedsToScanSymbols:YES];
	[self setSourceHighlighter:[[[WCSourceHighlighter alloc] initWithSourceScanner:[self sourceScanner]] autorelease]];
	[[self sourceHighlighter] setDelegate:self];
	[[self sourceScanner] scanTokens];
	
	[pool release];
	
	return YES;
}

- (void)updateChangeCount:(NSDocumentChangeType)change {
	BOOL wasDocumentEdited = [self isDocumentEdited];
	
	[super updateChangeCount:change];
	
	if (wasDocumentEdited != [self isDocumentEdited] && change != NSChangeCleared) {
		[self _updateFileEditedStatus];
		
		if ([self projectDocument]) {
			WCFile *file = [[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self];
			
			if ([self isDocumentEdited])
				[[[self projectDocument] unsavedFiles] addObject:file];
			else
				[[[self projectDocument] unsavedFiles] removeObject:file];
		}
	}
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

#pragma mark NSTextViewDelegate
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)view {
	return [self undoManager];
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
- (WCSourceFileDocument *)sourceFileDocument {
	return self;
}
#pragma mark WCSourceScannerDelegate
- (WCSourceHighlighter *)sourceHighlighterForSourceScanner:(WCSourceScanner *)scanner {
	return [self sourceHighlighter];
}

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
- (WCSourceScanner *)sourceScannerForSourceTextStorage:(WCSourceTextStorage *)textStorage {
	return [self sourceScanner];
}
#pragma mark WCSourceHighlighterDelegate

- (NSArray *)labelSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] labelNamesToLabelSymbols]];
	}
	else {
		[retval addObject:[[self sourceScanner] labelNamesToLabelSymbols]];
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)equateSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] equateNamesToEquateSymbols]];
	}
	else {
		NSDictionary *equateNamesToEquateSymbols = [[self sourceScanner] equateNamesToEquateSymbols];
		
		if (equateNamesToEquateSymbols)
			[retval addObject:equateNamesToEquateSymbols];
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)defineSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] defineNamesToDefineSymbols]];
	}
	else {
		NSDictionary *defineNamesToDefineSymbols = [[self sourceScanner] defineNamesToDefineSymbols];
		
		if (defineNamesToDefineSymbols)
			[retval addObject:defineNamesToDefineSymbols];
	}
	
	return [[retval copy] autorelease];
}
- (NSArray *)macroSymbolsForSourceHighlighter:(WCSourceHighlighter *)highlighter {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	if ([self projectDocument]) {
		for (WCSourceFileDocument *document in [[self projectDocument] sourceFileDocuments])
			[retval addObject:[[document sourceScanner] macroNamesToMacroSymbols]];
	}
	else {
		NSDictionary *macroNamesToMacroSymbols = [[self sourceScanner] macroNamesToMacroSymbols];
		
		if (macroNamesToMacroSymbols)
			[retval addObject:macroNamesToMacroSymbols];
	}
	
	return [[retval copy] autorelease];
}
#pragma mark *** Public Methods ***

- (void)reloadDocumentFromDisk; {
	NSMutableArray *textViewsAndSelectedRanges = [NSMutableArray arrayWithCapacity:0];
	for (NSLayoutManager *layoutManager in [[self textStorage] layoutManagers]) {
		for (NSTextContainer *textContainer in [layoutManager textContainers])
			[textViewsAndSelectedRanges addObject:[NSDictionary dictionaryWithObjectsAndKeys:[textContainer textView],@"textView",[NSValue valueWithRange:[[textContainer textView] selectedRange]],@"selectedRange", nil]];
	}
	
	[[self textStorage] replaceCharactersInRange:NSMakeRange(0, [[self textStorage] length]) withString:[NSString stringWithContentsOfURL:[self fileURL] encoding:[self fileEncoding] error:NULL]];
	[self setFileModificationDate:[[self fileURL] modificationDate]];
	
	NSUInteger stringLength = [[self textStorage] length];
	for (NSDictionary *dict in textViewsAndSelectedRanges) {
		NSRange selectedRange = [[dict objectForKey:@"selectedRange"] rangeValue];
		NSTextView *textView = [dict objectForKey:@"textView"];
		
		if (NSMaxRange(selectedRange) < stringLength)
			[textView setSelectedRange:selectedRange];
	}
}
#pragma mark Properties
@synthesize sourceScanner=_sourceScanner;
@synthesize sourceHighlighter=_sourceHighlighter;
@synthesize textStorage=_textStorage;
@synthesize projectDocument=_projectDocument;
@synthesize fileEncoding=_fileEncoding;
@dynamic undoTextView;
- (NSTextView *)undoTextView {
	if (!_undoTextView) {
		_undoTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		
		[[_undoTextView layoutManager] replaceTextStorage:[self textStorage]];
		
		[_undoTextView setDelegate:self];
		[_undoTextView setSelectable:YES];
		[_undoTextView setEditable:YES];
		[_undoTextView setAllowsDocumentBackgroundColorChange:NO];
		[_undoTextView setAllowsImageEditing:NO];
		[_undoTextView setAllowsUndo:YES];
		[_undoTextView setAutomaticDashSubstitutionEnabled:NO];
		[_undoTextView setAutomaticDataDetectionEnabled:NO];
		[_undoTextView setAutomaticLinkDetectionEnabled:NO];
		[_undoTextView setAutomaticQuoteSubstitutionEnabled:NO];
		[_undoTextView setAutomaticSpellingCorrectionEnabled:NO];
		[_undoTextView setAutomaticTextReplacementEnabled:NO];
		[_undoTextView setContinuousSpellCheckingEnabled:NO];
		[_undoTextView setDisplaysLinkToolTips:NO];
		[_undoTextView setGrammarCheckingEnabled:NO];
		[_undoTextView setImportsGraphics:NO];
		[_undoTextView setIncrementalSearchingEnabled:NO];
		[_undoTextView setRichText:NO];
		[_undoTextView setRulerVisible:NO];
		[_undoTextView setSmartInsertDeleteEnabled:NO];
		[_undoTextView setUsesFindBar:NO];
		[_undoTextView setUsesFindPanel:NO];
		[_undoTextView setUsesInspectorBar:NO];
		[_undoTextView setUsesRuler:NO];
	}
	return _undoTextView;
}
#pragma mark *** Private Methods ***
- (void)_updateFileEditedStatus {
	[self willChangeValueForKey:@"icon"];
	[self willChangeValueForKey:@"isEdited"];
	
	[[[[self projectDocument] sourceFileDocumentsToFiles] objectForKey:self] setEdited:[self isDocumentEdited]];
	
	[self didChangeValueForKey:@"icon"];
	[self didChangeValueForKey:@"isEdited"];
}

@end
