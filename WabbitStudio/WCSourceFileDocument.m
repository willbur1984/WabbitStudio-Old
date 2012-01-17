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

@interface WCSourceFileDocument ()

@end

@implementation WCSourceFileDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[_fileContents release];
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
	
	[super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];
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
	
	return [[string dataUsingEncoding:fileEncoding] writeToURL:url options:NSDataWritingAtomic error:outError];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSString *string = [NSString stringWithContentsOfURL:url usedEncoding:&_fileEncoding error:outError];
	
	if (!string)
		return NO;
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withString:string];
	[_sourceScanner scanTokens];
	
	return YES;
}

- (BOOL)isEdited {
	return [self isDocumentEdited];
}

- (NSDocument *)document {
	return self;
}

- (NSArray *)sourceTokensForSourceTextView:(WCSourceTextView *)textView {
	return [[self sourceScanner] tokens];
}
- (NSArray *)sourceSymbolsForSourceTextView:(WCSourceTextView *)textView; {
	return [[self sourceScanner] symbols];
}
- (WCSourceScanner *)sourceScannerForSourceTextView:(WCSourceTextView *)textView {
	return [self sourceScanner];
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

- (WCSourceHighlighter *)sourceHighlighterForSourceTextStorage:(WCSourceTextStorage *)textStorage {
	return [self sourceHighlighter];
}

- (NSString *)fileDisplayNameForSourceScanner:(WCSourceScanner *)scanner {
	return [self displayName];
}

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

- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName forProjectDocument:(WCProjectDocument *)projectDocument error:(NSError **)outError; {
	if (!(self = [super initWithContentsOfURL:url ofType:typeName error:outError]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}

@synthesize sourceScanner=_sourceScanner;
@synthesize sourceHighlighter=_sourceHighlighter;
@synthesize textStorage=_textStorage;
@synthesize projectDocument=_projectDocument;

@end
