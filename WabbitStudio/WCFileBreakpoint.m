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

static NSString *const WCFileBreakpointRangeKey = @"range";
static NSString *const WCFileBreakpointFileUUIDKey = @"fileUUID";

@implementation WCFileBreakpoint
- (void)dealloc {
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

+ (id)fileBreakpointWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithRange:range file:file projectDocument:projectDocument] autorelease];
}
- (id)initWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithType:WCBreakpointTypeFile address:0 page:0]))
		return nil;
	
	_range = range;
	_file = [file retain];
	_projectDocument = projectDocument;
	
	return self;
}

@synthesize projectDocument=_projectDocument;
@synthesize file=_file;
@synthesize range=_range;

@end
