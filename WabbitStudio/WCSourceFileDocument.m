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
#import "WCSourceTextViewController.h"
#import "WCSourceTextView.h"
#import "RSFindBarViewController.h"
#import "NSString+RSExtensions.h"
#import "WCEditorViewController.h"
#import "NSUserDefaults+RSExtensions.h"
#import "WCDocumentController.h"
#import "WCSourceFileWindowController.h"

@interface WCSourceFileDocument ()

@end

@implementation WCSourceFileDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
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

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSMutableString *string = [[[[self textStorage] string] mutableCopy] autorelease];
	
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
	
	return [[string dataUsingEncoding:_fileEncoding] writeToURL:url options:NSDataWritingAtomic error:outError];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSString *string = [NSString stringWithContentsOfURL:url usedEncoding:&_fileEncoding error:outError];
	
	if (!string)
		return NO;
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withString:string];
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_sourceScanner scanTokens];
	
	return YES;
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

- (WCSourceHighlighter *)sourceHighlighterForSourceTextStorage:(WCSourceTextStorage *)textStorage {
	return [self sourceHighlighter];
}

- (NSString *)fileDisplayNameForSourceScanner:(WCSourceScanner *)scanner {
	return [self displayName];
}

@synthesize sourceScanner=_sourceScanner;
@synthesize sourceHighlighter=_sourceHighlighter;
@synthesize textStorage=_textStorage;

@end
