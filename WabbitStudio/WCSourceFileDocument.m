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
#import "WCSplitView.h"

@interface WCSourceFileDocument ()

@end

@implementation WCSourceFileDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_sourceTextViewController release];
	[_secondSourceTextViewController release];
	[_splitView release];
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
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCSourceFileDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
	[super windowControllerDidLoadNib:windowController];
	
	_sourceScanner = [[WCSourceScanner alloc] initWithTextStorage:[self textStorage]];
	[_sourceScanner setDelegate:self];
	[_sourceScanner setNeedsToScanSymbols:YES];
	[_sourceScanner scanTokens];
	
	_sourceHighlighter = [[WCSourceHighlighter alloc] initWithSourceScanner:[self sourceScanner]];
	
	_sourceTextViewController = [[WCSourceTextViewController alloc] initWithSourceFileDocument:self];
	
	[[[self sourceTextViewController] view] setFrame:[[[windowController window] contentView] frame]];
	[[[windowController window] contentView] addSubview:[[self sourceTextViewController] view]];
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

- (IBAction)splitEditorWindow:(id)sender; {
	NSView *contentView = [[self windowForSheet] contentView];
	// close the split view
	if ([[contentView subviews] count] &&
		[[[contentView subviews] objectAtIndex:0] isKindOfClass:[NSSplitView class]]) {
		
	}
	// create the split view and add the second source text view controller's view to it
	else {
		_splitView = [[WCSplitView alloc] initWithFrame:[contentView frame]];
		[_splitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMinYMargin];
		[_splitView setAutoresizesSubviews:YES];
		[_splitView setDividerStyle:NSSplitViewDividerStyleThin];
		[_splitView setVertical:NO];
		[_splitView setDelegate:self];
		[_splitView setDividerColor:[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0]];
		
		[[[self sourceTextViewController] view] removeFromSuperviewWithoutNeedingDisplay];
		
		[contentView addSubview:_splitView];
		[_splitView setFrame:[contentView frame]];
		
		[_splitView addSubview:[[self sourceTextViewController] view]];
		
		_secondSourceTextViewController = [[WCSourceTextViewController alloc] initWithSourceFileDocument:self];
		
		[_splitView addSubview:[_secondSourceTextViewController view]];

		CGFloat subviewHeight = floor(NSHeight([contentView frame]));
		NSRect secondSubviewFrame = [[[_splitView subviews] objectAtIndex:1] frame];
		secondSubviewFrame.size.height = subviewHeight;
		
		[[[_splitView subviews] objectAtIndex:1] setFrame:secondSubviewFrame];
		
		[[self sourceHighlighter] performHighlightingInVisibleRange];
	}
}

@synthesize jumpBarViewController=_jumpBarViewController;
@synthesize sourceTextViewController=_sourceTextViewController;
@synthesize sourceScanner=_sourceScanner;
@synthesize sourceHighlighter=_sourceHighlighter;
@synthesize textStorage=_textStorage;

@end
