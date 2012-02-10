//
//  WCBuildTarget.m
//  WabbitStudio
//
//  Created by William Towe on 2/10/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildTarget.h"
#import "WCProject.h"

static NSString *const WCBuildTargetOutputTypeKey = @"outputType";
static NSString *const WCBuildTargetNameKey = @"name";
static NSString *const WCBuildTargetInputFileUUIDKey = @"inputFileUUID";
static NSString *const WCBuildTargetDefinesKey = @"defines";
static NSString *const WCBuildTargetIncludesKey = @"includes";
static NSString *const WCBuildTargetActiveKey = @"active";
static NSString *const WCBuildTargetGenerateCodeListingKey = @"generateCodeListing";
static NSString *const WCBuildTargetGenerateLabelFileKey = @"generateLabelFile";
static NSString *const WCBuildTargetSymbolsAreCaseSensitiveKey = @"symbolsAreCaseSensitive";

@implementation WCBuildTarget
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	_project = nil;
	[_name release];
	[_inputFile release];
	[_inputFileUUID release];
	[_defines release];
	[_includes release];
	[super dealloc];
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:[NSNumber numberWithUnsignedInteger:[self outputType]] forKey:WCBuildTargetOutputTypeKey];
	[retval setObject:[self name] forKey:WCBuildTargetNameKey];
	
	if ([self inputFile])
		[retval setObject:[[self inputFile] UUID] forKey:WCBuildTargetInputFileUUIDKey];
	
	[retval setObject:[[self defines] valueForKey:RSPlistArchivingPlistRepresentationKey] forKey:WCBuildTargetDefinesKey];
	[retval setObject:[[self includes] valueForKey:RSPlistArchivingPlistRepresentationKey] forKey:WCBuildTargetIncludesKey];
	
	[retval setObject:[NSNumber numberWithBool:[self isActive]] forKey:WCBuildTargetActiveKey];
	[retval setObject:[NSNumber numberWithBool:[self generateCodeListing]] forKey:WCBuildTargetGenerateCodeListingKey];
	[retval setObject:[NSNumber numberWithBool:[self generateLabelFile]] forKey:WCBuildTargetGenerateLabelFileKey];
	[retval setObject:[NSNumber numberWithBool:[self symbolsAreCaseSensitive]] forKey:WCBuildTargetSymbolsAreCaseSensitiveKey];
	
	return [[retval copy] autorelease];
}

- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_outputType = [[plistRepresentation objectForKey:WCBuildTargetOutputTypeKey] unsignedIntegerValue];
	_name = [[plistRepresentation objectForKey:WCBuildTargetNameKey] copy];
	_inputFileUUID = [[plistRepresentation objectForKey:WCBuildTargetInputFileUUIDKey] copy];
	
	_defines = [[NSMutableArray alloc] initWithCapacity:0];
	for (NSDictionary *definePlist in [plistRepresentation objectForKey:WCBuildTargetDefinesKey]) {
		
	}
	
	_includes = [[NSMutableArray alloc] initWithCapacity:0];
	for (NSDictionary *includePlist in [plistRepresentation objectForKey:WCBuildTargetIncludesKey]) {
		
	}
	
	_buildTargetFlags.active = [[plistRepresentation objectForKey:WCBuildTargetActiveKey] boolValue];
	_buildTargetFlags.generateCodeListing = [[plistRepresentation objectForKey:WCBuildTargetGenerateCodeListingKey] boolValue];
	_buildTargetFlags.generateLabelFile = [[plistRepresentation objectForKey:WCBuildTargetGenerateLabelFileKey] boolValue];
	_buildTargetFlags.symbolsAreCaseSensitive = [[plistRepresentation objectForKey:WCBuildTargetSymbolsAreCaseSensitiveKey] boolValue];
	
	return self;
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCBuildTarget *copy = [[[self class] alloc] init];
	
	copy->_outputType = _outputType;
	copy->_name = [_name copy];
	copy->_inputFile = [_inputFile retain];
	copy->_defines = [_defines mutableCopy];
	copy->_includes = [_includes mutableCopy];
	copy->_buildTargetFlags = _buildTargetFlags;
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCBuildTarget *copy = [[[self class] alloc] init];
	
	copy->_outputType = _outputType;
	copy->_name = [_name copy];
	copy->_inputFile = [_inputFile retain];
	
	copy->_defines = [[NSMutableArray alloc] initWithCapacity:[_defines count]];
	// TODO: copy each define
	
	copy->_includes = [[NSMutableArray alloc] initWithCapacity:[_includes count]];
	// TODO: copy each include
	
	copy->_buildTargetFlags = _buildTargetFlags;
	copy->_buildTargetFlags.active = NO;
	
	return copy;
}
#pragma mark *** Public Methods ***
+ (WCBuildTarget *)buildTargetWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType; {
	return [[[[self class] alloc] initWithName:name outputType:outputType] autorelease];
}
- (id)initWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType; {
	if (!(self = [super init]))
		return nil;
	
	_name = [name copy];
	_outputType = outputType;
	_defines = [[NSMutableArray alloc] initWithCapacity:0];
	_includes = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}
#pragma mark Properties
@synthesize outputType=_outputType;
@synthesize name=_name;
@synthesize inputFile=_inputFile;
@synthesize defines=_defines;
@dynamic mutableDefines;
- (NSMutableArray *)mutableDefines {
	return [self mutableArrayValueForKey:WCBuildTargetDefinesKey];
}
- (NSUInteger)countOfDefines {
	return [_defines count];
}
- (NSArray *)definesAtIndexes:(NSIndexSet *)indexes {
	return [_defines objectsAtIndexes:indexes];
}
- (void)insertDefines:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_defines insertObjects:array atIndexes:indexes];
}
- (void)removeDefinesAtIndexes:(NSIndexSet *)indexes {
	[_defines removeObjectsAtIndexes:indexes];
}
- (void)replaceDefinesAtIndexes:(NSIndexSet *)indexes withDefines:(NSArray *)array {
	[_defines replaceObjectsAtIndexes:indexes withObjects:array];
}
@synthesize includes=_includes;
@dynamic mutableIncludes;
- (NSMutableArray *)mutableIncludes {
	return [self mutableArrayValueForKey:WCBuildTargetIncludesKey];
}
- (NSUInteger)countOfIncludes {
	return [_includes count];
}
- (NSArray *)includesAtIndexes:(NSIndexSet *)indexes {
	return [_includes objectsAtIndexes:indexes];
}
- (void)insertIncludes:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_includes insertObjects:array atIndexes:indexes];
}
- (void)removeIncludesAtIndexes:(NSIndexSet *)indexes {
	[_includes removeObjectsAtIndexes:indexes];
}
- (void)replaceIncludesAtIndexes:(NSIndexSet *)indexes withIncludes:(NSArray *)array {
	[_includes replaceObjectsAtIndexes:indexes withObjects:array];
}
@dynamic active;
- (BOOL)isActive {
	return _buildTargetFlags.active;
}
- (void)setActive:(BOOL)active {
	_buildTargetFlags.active = active;
}
@dynamic generateCodeListing;
- (BOOL)generateCodeListing {
	return _buildTargetFlags.generateCodeListing;
}
- (void)setGenerateCodeListing:(BOOL)generateCodeListing {
	_buildTargetFlags.generateCodeListing = generateCodeListing;
}
@dynamic generateLabelFile;
- (BOOL)generateLabelFile {
	return _buildTargetFlags.generateLabelFile;
}
- (void)setGenerateLabelFile:(BOOL)generateLabelFile {
	_buildTargetFlags.generateLabelFile = generateLabelFile;
}
@dynamic symbolsAreCaseSensitive;
- (BOOL)symbolsAreCaseSensitive {
	return _buildTargetFlags.symbolsAreCaseSensitive;
}
- (void)setSymbolsAreCaseSensitive:(BOOL)symbolsAreCaseSensitive {
	_buildTargetFlags.symbolsAreCaseSensitive = symbolsAreCaseSensitive;
}
@end
