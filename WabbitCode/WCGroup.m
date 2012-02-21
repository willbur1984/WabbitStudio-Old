//
//  WCGroup.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCGroup.h"

static NSString *const WCGroupNameKey = @"name";

@implementation WCGroup
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_name release];
	[super dealloc];
}

- (NSString *)fileName {
	if ([[self name] length])
		return [self name];
	return [super fileName];
}
- (void)setFileName:(NSString *)fileName {
	[self setName:fileName];
}
- (NSImage *)fileIcon {
	return [NSImage imageNamed:@"Group"];
}

- (BOOL)isSourceFile {
	return NO;
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	if ([[self name] length])
		[retval setObject:[self name] forKey:WCGroupNameKey];
	
	return [[retval copy] autorelease];
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super initWithPlistRepresentation:plistRepresentation]))
		return nil;
	
	_name = [[plistRepresentation objectForKey:WCGroupNameKey] copy];
	
	return self;
}
#pragma mark *** Public Methods ***
+ (id)groupWithFileURL:(NSURL *)fileURL name:(NSString *)name; {
	return [[[[self class] alloc] initWithFileURL:fileURL name:name] autorelease];
}
- (id)initWithFileURL:(NSURL *)fileURL name:(NSString *)name; {
	if (!(self = [super initWithFileURL:fileURL]))
		return nil;
	
	_name = [name copy];
	
	return self;
}
#pragma mark Properties
@synthesize name=_name;

@end
