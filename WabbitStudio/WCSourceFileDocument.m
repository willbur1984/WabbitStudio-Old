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
//#import "RSDefines.h"
#import "WCJumpBarViewController.h"
#import "WCSourceTextStorage.h"
#import "WCSourceTextViewController.h"
#import "WCSourceTextView.h"
#import "RSFindBarViewController.h"
#import "NSString+RSExtensions.h"
#import "WCEditorViewController.h"
#import "NSUserDefaults+RSExtensions.h"

@interface WCSourceFileDocument ()
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;
@end

@implementation WCSourceFileDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_sourceTextViewController release];
	[_jumpBarViewController release];
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
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCSourceFileDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
	[super windowControllerDidLoadNib:windowController];
	
	if (_fileContents) {
		_textStorage = [[WCSourceTextStorage alloc] initWithString:_fileContents];
		
		[_fileContents release];
		_fileContents = nil;
	}
	else
		_textStorage = [[WCSourceTextStorage alloc] init];
	
	[_textStorage setDelegate:self];
	
	_sourceScanner = [[WCSourceScanner alloc] initWithTextStorage:[self textStorage]];
	[_sourceScanner setDelegate:self];
	[_sourceScanner setNeedsToScanSymbols:YES];
	[_sourceScanner scanTokens];
	
	_sourceHighlighter = [[WCSourceHighlighter alloc] initWithSourceScanner:[self sourceScanner]];
	
	_sourceTextViewController = [[WCSourceTextViewController alloc] initWithTextStorage:[self textStorage] sourceScanner:[self sourceScanner] sourceHighlighter:[self sourceHighlighter]];
	
	NSView *contentView = [[windowController window] contentView];
	NSRect contentViewFrame = [contentView frame];
	
	[contentView addSubview:[[self sourceTextViewController] view]];
	
	_jumpBarViewController = [[WCJumpBarViewController alloc] initWithTextView:(NSTextView *)[[self sourceTextViewController] textView] jumpBarDataSource:self];
	
	[contentView addSubview:[[self jumpBarViewController] view]];
	
	NSRect jumpBarViewFrame = [[[self jumpBarViewController] view] frame];
	
	[[[self sourceTextViewController] view] setFrame:NSMakeRect(NSMinX(contentViewFrame), NSMinY(contentViewFrame), NSWidth(contentViewFrame), NSHeight(contentViewFrame)-NSHeight(jumpBarViewFrame))];
	[[[self jumpBarViewController] view] setFrame:NSMakeRect(NSMinX(contentViewFrame), NSMaxY(contentViewFrame)-NSHeight(jumpBarViewFrame), NSWidth(contentViewFrame), NSHeight(jumpBarViewFrame))];
	
	//[[[self sourceTextViewController] view] setFrame:NSMakeRect(NSMinX(contentViewFrame), NSMinY(contentViewFrame), NSWidth(contentViewFrame), NSHeight(contentViewFrame))];
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
	NSMutableString *string = [[[[self textStorage] string] mutableCopy] autorelease];
	
	// remove any attachment characters
	[string replaceOccurrencesOfString:[NSString attachmentCharacterString] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	
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
	
	return [string dataUsingEncoding:_fileEncoding];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	NSString *string = [NSString stringWithContentsOfURL:url usedEncoding:&_fileEncoding error:outError];
	
	if (!string)
		return NO;
	
	_fileContents = [string retain];
	
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
	[[self undoManager] removeAllActions];
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

@synthesize jumpBarViewController=_jumpBarViewController;
@synthesize sourceTextViewController=_sourceTextViewController;
@synthesize sourceScanner=_sourceScanner;
@synthesize sourceHighlighter=_sourceHighlighter;
@synthesize textStorage=_textStorage;

@end
