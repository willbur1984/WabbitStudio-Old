//
//  WCSymbolFileContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSymbolFileContainer.h"
#import "WCProject.h"

@implementation WCSymbolFileContainer
- (BOOL)isLeafNode {
	return NO;
}

+ (id)symbolFileContainerWithFile:(WCFile *)file; {
	return [[(WCSymbolFileContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	return self;
}

@dynamic statusString;
- (NSString *)statusString {
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {
		NSUInteger symbolCount = 0;
		
		for (WCSymbolFileContainer *container in [self childNodes])
			symbolCount += [[container childNodes] count];
		
		return [NSString stringWithFormat:NSLocalizedString(@"%lu symbols total", @"total symbols format string"),symbolCount];
	}
	else {
		return [NSString stringWithFormat:NSLocalizedString(@"%lu symbols", @"symbols format string"),[[self childNodes] count]];
	}
}
@end
