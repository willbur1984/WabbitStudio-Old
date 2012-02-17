//
//  WCProject.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProject.h"
#import "WCProjectDocument.h"
#import "NSURL+RSExtensions.h"
#import "NSString+RSExtensions.h"
#import "WCBuildTarget.h"

static NSString *const WCProjectBuildTargetsKey = @"buildTargets";

@implementation WCProject
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	_document = nil;
	[super dealloc];
}

- (NSString *)fileName {
	return [[self document] displayName];
}
- (NSImage *)fileIcon {
	return [NSImage imageNamed:@"project"];
}
- (NSURL *)fileURL {
	return [[self document] fileURL];
}
- (NSString *)filePath {
	return [[self fileURL] path];
}
- (BOOL)isSourceFile {
	return NO;
}
- (BOOL)isEdited {
	return NO;
}
- (NSString *)fileUTI {
	return [[self fileURL] fileUTI];
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[retval setObject:[self className] forKey:RSObjectClassNameKey];
	[retval setObject:[self UUID] forKey:WCFileUUIDKey];
	
	return [[retval copy] autorelease];
}

#pragma mark *** Public Methods ***
+ (id)projectWithDocument:(WCProjectDocument *)document; {
	return [[(WCProject *)[[self class] alloc] initWithDocument:document] autorelease];
}
- (id)initWithDocument:(WCProjectDocument *)document; {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[NSString UUIDString] copy];
	_document = document;
	
	return self;
}
#pragma mark Properties
@synthesize document=_document;
@dynamic fileStatus;
- (NSString *)fileStatus {
	NSArray *buildTargets = [[self document] buildTargets];
	WCBuildTarget *activeBuildTarget = [[self document] activeBuildTarget];
	
	if ([buildTargets count] == 1) {
		if (activeBuildTarget)
			return [NSString stringWithFormat:NSLocalizedString(@"1 target, \"%@\" is active", @"1 target and active target format string"),[activeBuildTarget name]];
		return NSLocalizedString(@"1 target, no active target", @"1 target, no active target");
	}
	else if (activeBuildTarget)
		return [NSString stringWithFormat:NSLocalizedString(@"%lu targets, \"%@\" is active", @"multiple targets and active target format string"),[buildTargets count],[activeBuildTarget name]];
	return [NSString stringWithFormat:NSLocalizedString(@"%lu targets, no active target", @"multiple targets and no active target format string"),[buildTargets count]];
}
@end
