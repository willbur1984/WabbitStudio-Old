//
//  WCSearchContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSearchContainer.h"
#import "WCProject.h"

@implementation WCSearchContainer
- (BOOL)isLeafNode {
	return NO;
}

+ (id)searchContainerWithFile:(WCFile *)file; {
	return [[(WCSearchContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	return self;
}

@dynamic searchStatus;
- (NSString *)searchStatus {
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {
		NSUInteger total = 0;
		
		for (RSTreeNode *node in [self childNodes])
			total += [[node childNodes] count];
		
		if (total == 1)
			return NSLocalizedString(@"1 result total", @"1 result total");
		return [NSString stringWithFormat:NSLocalizedString(@"%lu results total", @"search container search status project format string"),total];
	}
	if ([[self childNodes] count] == 1)
		return NSLocalizedString(@"1 result", @"1 result");
	return [NSString stringWithFormat:NSLocalizedString(@"%lu results", @"search container search status format string"),[[self childNodes] count]];
}
@end
