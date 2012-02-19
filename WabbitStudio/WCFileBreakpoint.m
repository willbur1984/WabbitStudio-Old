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

static NSString *const WCFileBreakpointRangeKey = @"range";
static NSString *const WCFileBreakpointFileUUIDKey = @"fileUUID";

@implementation WCFileBreakpoint
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_projectDocument = nil;
	[_file release];
	[_fileUUID release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	WCFileBreakpoint *copy = [super copyWithZone:zone];
	
	copy->_range = _range;
	copy->_file = [_file retain];
	copy->_projectDocument = _projectDocument;
	
	return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	WCFileBreakpoint *copy = [super mutableCopyWithZone:zone];
	
	copy->_range = _range;
	copy->_file = [_file retain];
	copy->_projectDocument = _projectDocument;
	
	return copy;
}

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

- (NSImage *)icon {
	return [[self class] breakpointIconWithSize:NSMakeSize(24.0, 12.0) type:[self type] active:[self isActive] enabled:[[[self projectDocument] breakpointManager] breakpointsEnabled]];
}
- (NSString *)name {
	WCSourceFileDocument *sfDocument = [[[self projectDocument] filesToSourceFileDocuments] objectForKey:[self file]];
	NSString *string = [[sfDocument textStorage] string];
	
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - line %lu", @"file breakpoint name format string"),[[self file] fileName],[string lineNumberForRange:[self range]]+1];
}
+ (NSSet *)keyPathsForValuesAffectingName {
	return [NSSet setWithObjects:@"range", nil];
}

+ (id)fileBreakpointWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithRange:range file:file projectDocument:projectDocument] autorelease];
}
- (id)initWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithType:WCBreakpointTypeFile address:0 page:0]))
		return nil;
	
	_range = range;
	_file = [file retain];
	_projectDocument = projectDocument;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidChangeBreakpointsEnabled:) name:WCBreakpointManagerDidChangeBreakpointsEnabledNotification object:[projectDocument breakpointManager]];
	
	return self;
}

@synthesize projectDocument=_projectDocument;
- (void)setProjectDocument:(WCProjectDocument *)projectDocument {
	_projectDocument = projectDocument;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_breakpointManagerDidChangeBreakpointsEnabled:) name:WCBreakpointManagerDidChangeBreakpointsEnabledNotification object:[projectDocument breakpointManager]];
}
@synthesize file=_file;
@synthesize range=_range;

- (void)_breakpointManagerDidChangeBreakpointsEnabled:(NSNotification *)note {
	[self willChangeValueForKey:@"icon"];
	[self didChangeValueForKey:@"icon"];
}

@end
