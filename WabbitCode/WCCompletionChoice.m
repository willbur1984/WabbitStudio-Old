//
//  WCCompletionChoice.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
