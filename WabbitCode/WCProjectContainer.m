//
//  WCProjectContainer.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectContainer.h"
#import "WCFile.h"

@implementation WCProjectContainer
#pragma mark *** Subclass Overrides ***

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	NSMutableArray *childNodePlists = [NSMutableArray arrayWithCapacity:[[self childNodes] count]];
	for (RSTreeNode *node in [self childNodes])
		[childNodePlists addObject:[node plistRepresentation]];
	
	[retval setObject:childNodePlists forKey:RSTreeNodeChildNodesKey];
	
	return [[retval copy] autorelease];
}

- (NSURL *)locationURLForFile:(WCFile *)file {
	return [NSURL URLWithString:[file fileName]];
}

#pragma mark *** Public Methods ***
+ (id)projectContainerWithProject:(WCProject *)project; {
	return [[[[self class] alloc] initWithProject:project] autorelease];
}
- (id)initWithProject:(WCProject *)project; {
	if (!(self = [super initWithRepresentedObject:project]))
		return nil;
	
	
	return self;
}
#pragma mark Properties
@dynamic project;
- (WCProject *)project {
	return (WCProject *)[self representedObject];
}
@end
