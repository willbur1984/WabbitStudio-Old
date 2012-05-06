//
//  WCBuildDefine.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBuildDefine.h"

static NSString *const WCBuildDefineNameKey = @"name";
static NSString *const WCBuildDefineValueKey = @"value";

@implementation WCBuildDefine
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_name release];
	[_value release];
	[super dealloc];
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCBuildDefine *copy = [[[self class] alloc] initWithName:[self name] value:[self value]];
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCBuildDefine *copy = [[[self class] alloc] initWithName:[self name] value:[self value]];
	
	return copy;
}
#pragma mark RSPlistArchiving
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
#pragma mark *** Public Methods ***
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
#pragma mark Properties
@synthesize name=_name;
@synthesize value=_value;

@end
