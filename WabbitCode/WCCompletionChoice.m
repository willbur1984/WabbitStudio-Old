//
//  WCCompletionChoice.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCCompletionChoice.h"

@implementation WCCompletionChoice
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_name release];
	[_dictionary release];
	[super dealloc];
}

#pragma mark WCCompletionItem
- (NSString *)completionName {
	return [[self completionDictionary] objectForKey:WCCompletionItemArgumentNameKey];
}
- (NSString *)completionInsertionName {
	return [self name];
}
- (NSImage *)completionIcon {
	return [WCSourceToken sourceTokenIconForSourceTokenType:_type];
}
#pragma mark *** Public Methods ***
+ (id)completionChoiceOfType:(WCSourceTokenType)type name:(NSString *)name dictionary:(NSDictionary *)dictionary; {
	return [[[[self class] alloc] initWithType:type name:name dictionary:dictionary] autorelease];
}
- (id)initWithType:(WCSourceTokenType)type name:(NSString *)name dictionary:(NSDictionary *)dictionary; {
	if (!(self = [super init]))
		return nil;
	
	_type = type;
	_name = [name copy];
	_dictionary = [dictionary copy];
	
	return self;
}
#pragma mark Properties
@synthesize completionDictionary=_dictionary;
@synthesize name=_name;
@synthesize type=_type;
@end
