//
//  WCBuildDefine.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildDefine.h"

static NSString *const WCBuildDefineNameKey = @"name";
static NSString *const WCBuildDefineValueKey = @"value";

@implementation WCBuildDefine
- (void)dealloc {
	[_name release];
	[_value release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	WCBuildDefine *copy = [[[self class] alloc] initWithName:[self name] value:[self value]];
	
	return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	WCBuildDefine *copy = [[[self class] alloc] initWithName:[self name] value:[self value]];
	
	return copy;
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithDictionary:[super plistRepresentation]];
	
	[retval setObject:[self name] forKey:WCBuildDefineNameKey];
	
	if ([[self value] length])
		[retval setObject:[self value] forKey:WCBuildDefineValueKey];
	
	return [[retval copy] autorelease];
}

- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super init]))
		return nil;
	
	_name = [[plistRepresentation objectForKey:WCBuildDefineNameKey] copy];
	_value = [[plistRepresentation objectForKey:WCBuildDefineValueKey] copy];
	
	return self;
}

+ (id)buildDefine; {
	return [[[[self class] alloc] initWithName:NSLocalizedString(@"NEW_DEFINE", @"NEW_DEFINE")] autorelease];
}
+ (id)buildDefineWithName:(NSString *)name; {
	return [[[[self class] alloc] initWithName:name] autorelease];
}
- (id)initWithName:(NSString *)name; {
	return [self initWithName:name value:nil];
}
+ (id)buildDefineWithName:(NSString *)name value:(NSString *)value; {
	return [[[[self class] alloc] initWithName:name value:value] autorelease];
}
- (id)initWithName:(NSString *)name value:(NSString *)value; {
	if (!(self = [super init]))
		return nil;
	
	_name = [name copy];
	_value = [value copy];
	
	return self;
}

@synthesize name=_name;
@synthesize value=_value;

@end
