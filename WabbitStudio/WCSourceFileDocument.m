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
	
	_textStorage = [[WCSourceTextStorage alloc] init];
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
	
	if (_fileContents) {
		[[self textStorage] replaceCharactersInRange:NSMakeRange(0, 0) withString:_fileContents];
		
		[_fileContents release];
		_fileContents = nil;
	}
	
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
	NSString *string = [[self textStorage] string];
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	_fileContents = [string retain];
	
	return YES;
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
