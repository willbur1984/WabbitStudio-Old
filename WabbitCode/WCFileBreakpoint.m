//
//  WCFileBreakpoint.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFileBreakpoint.h"
#import "WCProjectDocument.h"
#import "WCFile.h"
#import "WCBreakpointManager.h"
#import "WCSourceFileDocument.h"
#import "WCSourceTextStorage.h"
#import "NSString+RSExtensions.h"
#import "WCSourceSymbol.h"
#import "WCSourceScanner.h"
#import "NSArray+WCExtensions.h"

static NSString *const WCFileBreakpointRangeKey = @"range";
static NSString *const WCFileBreakpointFileUUIDKey = @"fileUUID";

@interface WCFileBreakpoint ()
@property (readwrite,retain,nonatomic) WCSourceSymbol *symbol;
@end

@implementation WCFileBreakpoint
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_projectDocument = nil;
	[_symbol release];
	[_file release];
	[_fileUUID release];
	[super dealloc];
}

- (NSImage *)icon {
	return [[self class] breakpointIconWithSize:NSMakeSize(24.0, 12.0) type:[self type] active:[self isActive] enabled:[[[self projectDocument] breakpointManager] breakpointsEnabled]];
}
- (NSString *)fileNameAndLineNumber {
	WCSourceFileDocument *sfDocument = [[[self projectDocument] filesToSourceFileDocuments] objectForKey:[self file]];
	NSString *string = [[sfDocument textStorage] string];
	
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - line %lu", @"file breakpoint file name and line number format string"),[[self file] fileName],[string lineNumberForRange:[self range]]+1];
}
+ (NSSet *)keyPathsForValuesAffectingFileNameAndLineNumber {
	return [NSSet setWithObjects:@"range", nil];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCFileBreakpoint *copy = [super copyWithZone:zone];
	
	copy->_range = _range;
	copy->_file = [_file retain];
	copy->_projectDocument = _projectDocument;
	copy->_symbol = [_symbol retain];
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCFileBreakpoint *copy = [super mutableCopyWithZone:zone];
	
	copy->_range = _range;
	copy->_file = [_file retain];
	copy->_projectDocument = _projectDocument;
	copy->_symbol = [_symbol retain];
	
	return copy;
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:NSStringFromRange([self range]) forKey:WCFileBreakpointRangeKey];
	[retval setObject:[[self file] UUID] forKey:WCFileBreakpointFileUUIDKey];
	
	return [[retval copy] autorelease];
}

- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super initWithPlistRepresentation:plistRepresentation]))
		return nil;
	
	_range = NSRangeFromString([plistRepresentation objectForKey:WCFileBreakpointRangeKey]);
	_fileUUID = [[plistRepresentation objectForKey:WCFileBreakpointFileUUIDKey] copy];
	
	return self;
}
#pragma mark *** Public Methods ***
+ (id)fileBreakpointWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithRange:range file:file projectDocument:projectDocument] autorelease];
}
- (id)initWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithType:WCBreakpointTypeFile address:UINT16_MAX page:UINT8_MAX]))
		return nil;
	
	_range = range;
	_file = [file retain];
	_projectDocument = projectDocument;
	
	WCSourceFileDocument *sfDocument = [[projectDocument filesToSourceFileDocuments] objectForKey:[self file]];
	NSArray *symbols = [[sfDocument sourceScanner] symbols];
	NSString *string = [[sfDocument textStorage] string];
	
	_symbol = [[symbols sourceSymbolForRange:range] retain];
	_name = [[NSString stringWithFormat:NSLocalizedString(@"%@ - line %lu", @"file breakpoint name format string"),[_symbol name],[string lineNumberForRange:range]+1] copy];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidChangeBreakpointsEnabled:) name:WCBreakpointManagerDidChangeBreakpointsEnabledNotification object:[projectDocument breakpointManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanningSymbols:) name:WCSourceScannerDidFinishScanningSymbolsNotification object:[sfDocument sourceScanner]];
	
	return self;
}
#pragma mark Properties
@synthesize projectDocument=_projectDocument;
- (void)setProjectDocument:(WCProjectDocument *)projectDocument {
	_projectDocument = projectDocument;
	
	WCFile *file = [[projectDocument UUIDsToFiles] objectForKey:_fileUUID];
	
	_file = [file retain];
	
	WCSourceFileDocument *sfDocument = [[projectDocument filesToSourceFileDocuments] objectForKey:[self file]];
	NSArray *symbols = [[sfDocument sourceScanner] symbols];
	NSString *string = [[sfDocument textStorage] string];
	
	_symbol = [[symbols sourceSymbolForRange:[self range]] retain];
	_name = [[NSString stringWithFormat:NSLocalizedString(@"%@ - line %lu", @"file breakpoint name format string"),[_symbol name],[string lineNumberForRange:[self range]]+1] copy];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidChangeBreakpointsEnabled:) name:WCBreakpointManagerDidChangeBreakpointsEnabledNotification object:[projectDocument breakpointManager]];
}
@synthesize file=_file;
@synthesize range=_range;
- (void)setRange:(NSRange)range {
	_range = range;
	
	WCSourceFileDocument *sfDocument = [[[self projectDocument] filesToSourceFileDocuments] objectForKey:[self file]];
	NSArray *symbols = [[sfDocument sourceScanner] symbols];
	NSString *string = [[sfDocument textStorage] string];
	
	[self setSymbol:[symbols sourceSymbolForRange:range]];
	[self setName:[NSString stringWithFormat:NSLocalizedString(@"%@ - line %lu", @"file breakpoint name format string"),[[self symbol] name],[string lineNumberForRange:range]+1]];
}
@synthesize symbol=_symbol;
#pragma mark *** Private Methods ***

#pragma mark Notifications
- (void)_breakpointManagerDidChangeBreakpointsEnabled:(NSNotification *)note {
	[self willChangeValueForKey:@"icon"];
	[self didChangeValueForKey:@"icon"];
}
- (void)_sourceScannerDidFinishScanningSymbols:(NSNotification *)note {
	WCSourceFileDocument *sfDocument = [[[self projectDocument] filesToSourceFileDocuments] objectForKey:[self file]];
	NSArray *symbols = [[sfDocument sourceScanner] symbols];
	
	[self setSymbol:[symbols sourceSymbolForRange:[self range]]];
}

@end
